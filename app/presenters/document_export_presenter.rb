class DocumentExportPresenter
  attr_reader :format

  def initialize(format)
    @format = format
  end

  def header_row
    (common_fields + format_specific_fields).map { |s| s.to_s.humanize }
  end

  def parse_document(document)
    parsed_common_fields = common_fields.map do |field|
      document.public_send(field)
    end

    parsed_format_specific_fields = format_specific_fields.map do |field|
      value = format.finder_schema.humanized_facet_value(field.to_s, document.public_send(field))
      value.is_a?(Array) ? value.join(";") : value.to_s
    end

    parsed_common_fields + parsed_format_specific_fields
  end

private

  def common_fields
    system_fields = %i[
      state_history
      last_edited_at
      public_updated_at
      first_published_at
      update_type
      bulk_published
      temporary_update_type
      warnings
      disable_email_alert
    ].freeze

    format::COMMON_FIELDS - system_fields
  end

  def format_specific_fields
    format::FORMAT_SPECIFIC_FIELDS
  end
end
