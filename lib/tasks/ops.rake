namespace :ops do
  desc "Discard the draft of document"
  task :discard, %i[content_id locale] => :environment do |_, args|
    OpsTasks.discard(args.content_id, args.locale)
  end

  desc "Set the public_updated_at for a published document"
  task :set_public_updated_at, %i[content_id locale timestamp] => :environment do |_, args|
    OpsTasks.set_public_updated_at(args.content_id, args.locale, args.timestamp)
  end
end
