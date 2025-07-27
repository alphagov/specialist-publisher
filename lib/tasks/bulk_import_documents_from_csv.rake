desc "Import design decisions from a CSV file and save them with optional attachments"

task :bulk_import_documents_from_csv, %i[csv_file_path] => :environment do |_, args|
  require "json"

  csv_file_path = args[:csv_file_path]

  unless File.exist?(csv_file_path)
    puts "CSV file not found"
    exit
  end

  imported_count = 0
  skipped_rows = []

  CSV.foreach(csv_file_path, headers: true).with_index(2) do |row, line_number|
    title = row["title"]
    summary = row["summary"]&.delete('"')
    body = row["body"]&.delete('"')

    design_decision_british_library_number = get_design_decision_british_library_number(title)
    design_decision_date = get_design_decision_date(summary)

    design_decision_litigants = get_design_decision_litigants(body)
    design_decision_hearing_officer = get_design_decision_hearing_officer(body)
    note_body = get_note_body(body)

    required_fields = {
      "title" => title,
      "summary" => summary,
      "body" => body,
      "design_decision_litigants" => design_decision_litigants,
      "design_decision_hearing_officer" => design_decision_hearing_officer,
      "design_decision_british_library_number" => design_decision_british_library_number,
      "design_decision_date" => design_decision_date,
    }

    if required_fields.values.any?(&:blank?)
      skipped_rows << {
        line: line_number,
        missing_fields: required_fields.select { |_, v| v.blank? }.keys,
        title: title,
      }
      next
    end

    design_decision = DesignDecision.new(title: title,
                                         summary: summary,
                                         design_decision_litigants: design_decision_litigants,
                                         design_decision_hearing_officer: design_decision_hearing_officer,
                                         design_decision_british_library_number: design_decision_british_library_number,
                                         design_decision_date: design_decision_date,
                                         body: note_body)

    if row["attachment_title"].present? && row["attachment_filename"].present? && row["attachment_url"].present?
      design_decision.attachments.build(
        title: row["attachment_title"],
        filename: row["attachment_filename"],
        url: row["attachment_url"],
        created_at: row["attachment_created_at"].present? ? Time.zone.parse(row["attachment_created_at"]) : nil,
        updated_at: row["attachment_updated_at"].present? ? Time.zone.parse(row["attachment_updated_at"]) : nil,
      )
    end

    design_decision.save
    imported_count += 1
  end

  puts "Imported: #{imported_count} document(s)"
  puts "Skipped: #{skipped_rows.count} row(s)"

  if skipped_rows.any?
    puts "\nSkipped row details:"
    skipped_rows.each do |row|
      puts "- Line #{row[:line]}: Missing #{row[:missing_fields].join(', ')} (Title: #{row[:title] || 'N/A'})"
    end
  end
end

def get_hearing_officer_mapping
  schema_path = Rails.root.join("lib/documents/schemas/design_decisions.json")
  schema = JSON.parse(File.read(schema_path))
  officer_facet = schema["facets"].find { |f| f["key"] == "design_decision_hearing_officer" }
  officer_facet["allowed_values"].to_h { |val| [val["label"], val["value"]] }
end

def get_design_decision_british_library_number(title)
  title[/Design hearing decision:\s*(\S+)/i, 1] if title
end

def get_design_decision_date(summary)
  raw_date = summary[/\b\d{1,2} \w+ \d{4}\b/] if summary
  raw_date ? Date.parse(raw_date).strftime("%Y-%m-%d") : nil
end

def get_design_decision_litigants(body)
  body[/\|\s*.*?litigants.*?\s*\|\s*(.+?)\s*\|/i, 1] if body
end

def get_design_decision_hearing_officer(body)
  if body
    officer_label =
      body[/\|\s*.*?hearing\s*officer.*?\s*\|\s*(.+?)\s*\|/i, 1] ||
      body[/\|\s*.*?appointed\s*person.*?\s*\|\s*(.+?)\s*\|/i, 1]
  end
  get_hearing_officer_mapping[officer_label]
end

def get_note_body(body)
  start_index = body&.lines&.find_index { |line| line.match?(/^.*Every effort.*$/i) }
  start_index ? body.lines[start_index..].join.strip : nil
end
