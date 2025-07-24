desc "Import design decisions from a CSV file and save them with optional attachments"

task :bulk_import_documents_from_csv, %i[csv_file_path] => :environment do |_, args|
  csv_file_path = args[:csv_file_path]

  unless File.exist?(csv_file_path)
    puts "CSV file not found"
    exit
  end

  hearing_officer_allowed_values = get_hearing_officer_allowed_values

  CSV.foreach(csv_file_path, headers: true) do |row|
    title = row["title"]
    summary = row["summary"]&.delete('"')
    body = row["body"]&.delete('"')
    design_decision_litigants = get_design_decision_litigants(body)
    design_decision_hearing_officer = get_design_decision_hearing_officer(body, hearing_officer_allowed_values)
    design_decision_british_library_number = get_design_decision_british_library_number(title)
    design_decision_date = get_design_decision_date(summary)
    note_body = get_note_body(body)

    design_decision = DesignDecision.new(title: title,
                                         summary: summary,
                                         design_decision_litigants: design_decision_litigants,
                                         design_decision_hearing_officer: design_decision_hearing_officer,
                                         design_decision_british_library_number: design_decision_british_library_number,
                                         design_decision_date: design_decision_date,
                                         body: note_body)

    if design_decision_has_attachment?(row)
      design_decision.attachments.build(
        title: row["attachment_title"],
        filename: row["attachment_filename"],
        url: row["attachment_url"],
        content_type: "application/pdf",
        created_at: row["attachment_created_at"].present? ? Time.zone.parse(row["attachment_created_at"]) : nil,
        updated_at: row["attachment_updated_at"].present? ? Time.zone.parse(row["attachment_updated_at"]) : nil,
      )
    end

    design_decision.save
  end
end

def get_hearing_officer_allowed_values
  FinderSchema.load_from_schema("design_decisions")
              .allowed_values_for("design_decision_hearing_officer")
              .to_h { |val| [val.fetch("label"), val.fetch("value")] }
end

def get_humanised_hearing_officer(body)
  if body
    hearing_officer_line = body.lines.find { |line| line.match?(/Hearing Officer|Appointed Person/i) }

    if hearing_officer_line
      cleaned_line = hearing_officer_line.gsub(/<[^>]+>|\*\*/, "")
      match = cleaned_line.match(/\|?\s*(?:Hearing Officer|Appointed Person)\s*\|\s*(.+?)(?:\||$)/i)
      match[1].strip if match
    end
  end
end

def get_design_decision_hearing_officer(body, hearing_officers)
  humanised_hearing_officer = get_humanised_hearing_officer(body)&.strip
  hearing_officers.fetch(humanised_hearing_officer, nil)
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
