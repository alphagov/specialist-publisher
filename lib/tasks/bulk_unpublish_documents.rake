# Unpublishes every document in a given CSV file.
# The tasks uses `DocumentUnpublisher`, so:
# If 'alternative_path' is given, the unpublishing type will be 'redirect' (to that url)
# otherwise it will be 'gone'.  This replicates what happens when you unpublish via the UI.

desc "Bulk unpublish documents from a CSV file"

task :bulk_unpublish_documents, %i[csv_file_path dry_run] => :environment do |_, args|
  csv_file_path = args[:csv_file_path]
  dry_run = args[:dry_run].to_s.downcase == "true"

  unless File.exist?(csv_file_path)
    raise StandardError, "File not found: #{csv_file_path}"
  end

  puts "Parsing CSV: #{csv_file_path}..."
  invalid_rows = []
  docs_to_unpublish = []

  CSV.foreach(csv_file_path, headers: true).with_index(2) do |row, line_number|
    required_fields = {
      title: row["title"],
      content_id: row["content_id"],
      base_path: row["base_path"],
      locale: row["locale"],
    }

    alternative_path = row["alternative_path"]

    if required_fields.values.any?(&:blank?)
      invalid_rows << {
        line: line_number,
        missing_fields: required_fields.select { |_, v| v.blank? }.keys,
      }
    else
      docs_to_unpublish << {
        **required_fields,
        alternative_path:,
      }
    end
  end

  if invalid_rows.any?
    puts invalid_rows
    raise StandardError, "CSV import failed: #{invalid_rows.count} row(s) have missing required fields."
  end

  puts "CSV parsed: #{docs_to_unpublish.count} valid row(s) found"

  if dry_run
    puts "=== DRY RUN RESULTS ==="
    puts "would unpublish #{docs_to_unpublish.count} and redirect #{docs_to_unpublish.select { |d| d[:alternative_path].present? }.count} documents"
    docs_to_unpublish.each do |doc|
      puts doc_message(doc)
    end
  end

  unless dry_run
    puts "Starting bulk unpublishing..."
    docs_to_unpublish.each do |doc|
      puts "Attempting to unpublish #{doc[:title]} - #{doc[:content_id]}..."
      DocumentUnpublisher.unpublish(doc[:content_id], doc[:locale], doc[:base_path], doc[:alternative_path])
      puts doc_message(doc)
    end
    puts "Done"
  end
end

def doc_message(doc)
  msg = "UNPUBLISHED Document #{doc[:title]}"
  msg += "\n & REDIRECTED to #{doc[:alternative_path]}" if doc[:alternative_path].present?
  msg
end
