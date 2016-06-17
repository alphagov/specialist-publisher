desc "Discard the draft of document"
task :discard, [:content_id] => :environment do |_, args|
  unless Document.find(args.content_id).discard
    puts "Document failed to discard."
  end
end
