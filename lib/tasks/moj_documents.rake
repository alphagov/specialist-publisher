namespace :moj_documents do
  desc "publish selected MOJ docs"
  task :publish, [:file_name] => :environment do |_, args|
    content_ids = []
    CSV.foreach(args.file_name) { |row| content_ids << row[0] }

    content_ids.each do |content_id|
      puts "Publishing #{content_id}"
      PublishWorker.perform_async(content_id)
    end
  end
end
