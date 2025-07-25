task :bulk_import_documents_from_csv, %i[csv_file_path] => :environment do |_, args|
  csv_file_path = args[:csv_file_path]

  unless File.exist?(csv_file_path)
    puts "CSV file not found"
    exit
  end

  CSV.foreach(csv_file_path, headers: true) do |row|
    body = row["body"]&.delete('"')
    design_decision_litigants = body[/\|\s*.*?litigants.*?\s*\|\s*(.+?)\s*\|/i, 1]
    design_decision_hearing_officer = body[/\|\s*.*?hearing\s*officer.*?\s*\|\s*(.+?)\s*\|/i, 1]
    DesignDecision.new(title: row["title"],
                       summary: row["summary"]&.delete('"'),
                       design_decision_litigants: design_decision_litigants,
                       design_decision_hearing_officer: design_decision_hearing_officer,
                       body: body)
  end
end