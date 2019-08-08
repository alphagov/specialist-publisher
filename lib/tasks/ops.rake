namespace :ops do
  desc "Discard the draft of document"
  task :discard, [:content_id] => :environment do |_, args|
    OpsTasks.discard(args.content_id)
  end

  desc "Send an email for document"
  task :email, [:content_id] => :environment do |_, args|
    OpsTasks.email(args.content_id)
  end

  desc "Set the public_updated_at for a published document"
  task :set_public_updated_at, %i[content_id timestamp] => :environment do |_, args|
    OpsTasks.set_public_updated_at(args.content_id, args.timestamp)
  end
end
