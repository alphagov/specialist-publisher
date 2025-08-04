desc "Import design decisions from a CSV file and save them with optional attachments"

task :bulk_import_documents_from_csv, %i[csv_file_path mapping_file_path dry_run] => :environment do |_, args|
  csv_file_path = args[:csv_file_path]
  mapping_file_path = args[:mapping_file_path]
  dry_run = args[:dry_run].to_s.downcase == "true"

  unless File.exist?(csv_file_path)
    puts "CSV file not found"
    exit
  end

  hearing_officers = get_hearing_officers_from_schema.merge(get_hearing_officers_from_csv(mapping_file_path))
  imported_count = 0
  invalid_rows = []

  documents_to_import = []

  CSV.foreach(csv_file_path, headers: true).with_index(2) do |row, line_number|
    title = row["title"]
    summary = row["summary"]&.delete('"')
    body = row["body"]&.delete('"')
    design_decision_litigants = get_design_decision_litigants(body)
    design_decision_hearing_officer = get_design_decision_hearing_officer(body, hearing_officers)
    design_decision_british_library_number = get_design_decision_british_library_number(title)
    design_decision_date = get_design_decision_date(summary)
    note_body = get_note_body(body)

    required_fields = {
      "title" => title,
      "summary" => summary,
      "body" => note_body,
      "design_decision_litigants" => design_decision_litigants,
      "design_decision_hearing_officer" => design_decision_hearing_officer,
      "design_decision_british_library_number" => design_decision_british_library_number,
      "design_decision_date" => design_decision_date,
    }

    if required_fields.values.any?(&:blank?)
      invalid_rows << {
        line: line_number,
        missing_fields: required_fields.select { |_, v| v.blank? }.keys,
        title: title,
      }
    else
      documents_to_import << { row: row, attributes: required_fields }
    end
  end

  if invalid_rows.any? && !dry_run
    raise StandardError, "CSV import failed: #{invalid_rows.count} row(s) have missing required fields."
  end

  documents_to_import.each do |document_data|
    design_decision = DesignDecision.new(**document_data[:attributes].deep_symbolize_keys)

    if design_decision_has_attachment?(document_data[:row])
      design_decision.attachments.build(
        title: document_data[:row]["attachment_title"],
        filename: document_data[:row]["attachment_filename"],
        url: document_data[:row]["attachment_url"],
        content_type: "application/pdf",
        created_at: document_data[:row]["attachment_created_at"].present? ? Time.zone.parse(document_data[:row]["attachment_created_at"]) : nil,
        updated_at: document_data[:row]["attachment_updated_at"].present? ? Time.zone.parse(document_data[:row]["attachment_updated_at"]) : nil,
      )
    end

    design_decision.save unless dry_run
    imported_count += 1
  end

  report_import_result(imported_count, invalid_rows, dry_run)
end

def get_hearing_officers_from_schema
  FinderSchema.load_from_schema("design_decisions")
              .allowed_values_for("design_decision_hearing_officer")
              .to_h { |val| [val.fetch("label"), val.fetch("value")] }
end

def get_hearing_officers_from_csv(mapping_file_path)
  custom_officer_mapping = {}
  if mapping_file_path.present? && File.exist?(mapping_file_path)
    CSV.foreach(mapping_file_path, headers: true) do |row|
      custom_officer_mapping[row["label"]] = row["value"]
    end
  end
  custom_officer_mapping
end

def get_design_decision_hearing_officer(body, hearing_officers)
  if body
    officer_label =
      body[/\|\s*.*?hearing\s*officer.*?\s*\|\s*(.+?)\s*\|/im, 1] ||
      body[/\|\s*.*?appointed\s*person.*?\s*\|\s*(.+?)\s*\|/im, 1]
  end
  hearing_officers.fetch(officer_label, nil)
end

def design_decision_has_attachment?(row)
  row["attachment_title"].present? && row["attachment_filename"].present? && row["attachment_url"].present?
end

def get_design_decision_british_library_number(title)
  title[/([O0]\/\d+\/\d+)/i, 1] if title
end

def get_design_decision_litigants(body)
  body[/\|\s*.*?litigants.*?\s*\|\s*(.+?)\s*\|/i, 1] if body
end

def get_note_body(body)
  start_index = body&.lines&.find_index { |line| line.match?(/^.*Every effort.*$/i) }
  start_index ? body.lines[start_index..].join.strip : nil
end

def get_design_decision_date(summary)
  raw_date = summary[/\b\d{1,2} \w+ \d{4}\b/] if summary
  raw_date ? Date.parse(raw_date).strftime("%Y-%m-%d") : nil
end

def report_import_result(imported_count, skipped_rows, dry_run)
  dry_run_prefix = dry_run ? "[DRY RUN] " : ""
  puts "#{dry_run_prefix}Imported: #{imported_count} document(s)"
  puts "Skipped: #{skipped_rows.count} row(s)"

  if skipped_rows.any?
    puts "\nSkipped row details:"
    skipped_rows.each do |row|
      puts "- Line #{row[:line]}: Missing #{row[:missing_fields].join(', ')} (Title: #{row[:title] || 'N/A'})"
    end
  end
end
