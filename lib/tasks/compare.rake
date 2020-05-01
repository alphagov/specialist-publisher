desc "Compare the data for a document before and after saving it"
task :compare, [:content_id] => :environment do |_, args|
  DataComparison.compare(args.content_id)
end

desc "Compare data for all documents before and after saving them"
task :compare_all, [:document_type] => :environment do |_, args|
  results = Services
    .publishing_api
    .get_content_items(
      document_type: args.document_type,
      per_page: 99999,
      fields: %w[content_id],
    ).to_hash.fetch("results")

  content_ids = results.map { |r| r.fetch("content_id") }

  content_ids.each do |content_id|
    DataComparison.compare(content_id)
  end
end
