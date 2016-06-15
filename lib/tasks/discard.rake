desc "Discard the draft of document"
task :discard, [:content_id] => :environment do |_, args|
  Document.find(args.content_id).discard!
end
