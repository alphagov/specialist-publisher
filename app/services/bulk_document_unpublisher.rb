require "csv"
require "services"

class BulkDocumentUnpublisher
  REQUIRED_HEADERS = %w[base_path alternative_path].freeze
  VALID_PATH = %r{\A/[/.a-zA-Z0-9-]+\z}
  LOCALE = "en".freeze

  attr_reader :errors, :rows

  def initialize(format, raw_csv)
    @format = format
    @raw_csv = raw_csv
    @errors = []
    @rows = []
  end

  def validate
    @errors = []
    @rows = []

    if @raw_csv.blank?
      errors << "Enter the CSV contents"
      return
    end

    table = parse_csv
    return if table.nil?
    return unless headers_valid?(table)

    if table.count.zero?
      errors << "Enter at least one row of CSV data"
      return
    end

    candidates = validate_rows(table)
    return if errors.any?

    @rows = resolve_content_ids(candidates)
  end

  def valid?
    errors.empty?
  end

  def summarise_changes
    rows.map do |row|
      action = if row[:alternative_path]
                 "Unpublish and redirect to #{row[:alternative_path]}"
               else
                 "Unpublish"
               end

      { base_path: row[:base_path], action: }
    end
  end

  def call
    rows.each_with_object([]) do |row, failures|
      failures << row[:base_path] unless unpublish(row)
    end
  end

private

  def parse_csv
    CSV.parse(@raw_csv, headers: true)
  rescue CSV::MalformedCSVError
    errors << "Malformed CSV, check for extra spaces or quotation marks"
    nil
  end

  def headers_valid?(table)
    detected = table.headers.compact.map(&:strip)
    return true if detected.sort == REQUIRED_HEADERS.sort

    errors << "Expected the following headers: #{REQUIRED_HEADERS.join(', ')}. Detected: #{detected.join(', ')}"
    false
  end

  def validate_rows(table)
    candidates = table.each_with_index.filter_map do |row, index|
      validate_row(row, index + 2)
    end

    duplicate_base_paths(candidates).each do |base_path|
      errors << "#{base_path} appears more than once"
    end

    candidates
  end

  def validate_row(row, line_number)
    if row.fields.count > REQUIRED_HEADERS.count
      errors << "Row #{line_number}: expected #{REQUIRED_HEADERS.count} fields but found #{row.fields.count}"
      return nil
    end

    base_path = row["base_path"].to_s.strip.presence
    alternative_path = row["alternative_path"].to_s.strip.presence

    if base_path.nil?
      errors << "Row #{line_number}: enter a base path"
      return nil
    end

    unless base_path.start_with?("#{finder_base_path}/")
      errors << "Row #{line_number}: #{base_path} is not a #{@format.title} path. Base paths must start with #{finder_base_path}/"
      return nil
    end

    if alternative_path && !alternative_path.match?(VALID_PATH)
      errors << "Row #{line_number}: #{alternative_path} is not a valid path. It must start with a slash, for example #{finder_base_path}/another-case"
      return nil
    end

    { base_path:, alternative_path: }
  end

  def duplicate_base_paths(candidates)
    candidates.map { |candidate| candidate[:base_path] }
              .tally
              .select { |_, count| count > 1 }
              .keys
  end

  def resolve_content_ids(candidates)
    lookups = Services.publishing_api.lookup_content_ids(
      base_paths: candidates.map { |candidate| candidate[:base_path] },
    )

    candidates.filter_map do |candidate|
      content_id = lookups[candidate[:base_path]]

      if content_id
        candidate.merge(content_id:)
      else
        errors << "Document not found: #{candidate[:base_path]}"
        nil
      end
    end
  end

  def unpublish(row)
    document = @format.find(row[:content_id], LOCALE)
    document.unpublish(row[:alternative_path])
  rescue DocumentFinder::RecordNotFound, DocumentFinder::TypeMismatchError, GdsApi::HTTPErrorResponse => e
    Rails.logger.error("Bulk unpublishing failed for #{row[:base_path]}: #{e.message}")
    GovukError.notify(e)
    false
  end

  def finder_base_path
    @format.finder_schema.base_path
  end
end
