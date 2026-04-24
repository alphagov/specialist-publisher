namespace :ops do
  desc "Discard the draft of document"
  task :discard, %i[content_id locale] => :environment do |_, args|
    OpsTasks.discard(args.content_id, args.locale)
  end

  desc "Set the public_updated_at for a published document"
  task :set_public_updated_at, %i[content_id locale timestamp] => :environment do |_, args|
    OpsTasks.set_public_updated_at(args.content_id, args.locale, args.timestamp)
  end

  desc "Override the first_published_at for a published document"
  # Call with bundle exec rake ops:override_first_published_at[content_id,locale,timestamp], e.g. ops:override_first_published_at['1234-5678-9012-3456','en','2024-01-01T12:00:00Z']
  # This change will not send an email to users subscribed to the finder, nor to user subscribed to the finder organisation.
  # Be mindful that this change should be consistent with any further change note history, i.e. the first_published_at should not be after any change note timestamp.
  task :override_first_published_at, %i[content_id locale timestamp] => :environment do |_, args|
    OpsTasks.override_first_published_at(args.content_id, args.locale, args.timestamp)
  end
end
