task :bulk_import_documents_from_csv, %i[csv_file_path] => :environment do |_, args|
  csv_file_path = args[:csv_file_path]

  unless File.exist?(csv_file_path)
    puts "CSV file not found"
    exit
  end

  CSV.foreach(csv_file_path, headers: true) do |row|
    title = row["title"]
    design_decision_british_library_number = title[/Design hearing decision:\s*(\S+)/i, 1]

    summary = row["summary"]&.delete('"')
    raw_date = summary[/\b\d{1,2} \w+ \d{4}\b/]
    design_decision_date = raw_date ? Date.parse(raw_date).strftime("%Y-%m-%d") : nil

    body = row["body"]&.delete('"')
    design_decision_litigants = body[/\|\s*.*?litigants.*?\s*\|\s*(.+?)\s*\|/i, 1]
    design_decision_hearing_officer = body[/\|\s*.*?hearing\s*officer.*?\s*\|\s*(.+?)\s*\|/i, 1]
    start_index = body.lines.find_index { |line| line.match?(/^.*Every effort.*$/i) }
    note_body = start_index ? body.lines[start_index..-1].join.strip : nil
    design_decision = DesignDecision.new(title: title,
                       summary: summary,
                       design_decision_litigants: design_decision_litigants,
                       design_decision_hearing_officer: design_decision_hearing_officer,
                       design_decision_british_library_number: design_decision_british_library_number,
                       design_decision_date: design_decision_date,
                       body: note_body)
    design_decision.save
  end
end