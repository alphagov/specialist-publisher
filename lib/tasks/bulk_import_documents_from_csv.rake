task :bulk_import_documents_from_csv, %i[csv_file_path] => :environment do |_, args|
  csv_file_path = args[:csv_file_path]

  unless File.exist?(csv_file_path)
    puts "CSV file not found"
    exit
  end

  CSV.foreach(csv_file_path, headers: true) do |row|
    DesignDecision.new(title: row["title"],
                       summary: row["summary"]&.delete('"'),
                       body: row["body"]&.delete('"'))
  end
end