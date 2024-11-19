# At present, these tasks will only republish documents that are in a draft,
# published or republished state.
require "services"

namespace :republish do
  desc "republish all documents"
  task all: :environment do
    Republisher.republish_all
  end

  desc "republish all documents for the given document type"
  task :document_type, [:document_type] => :environment do |_, args|
    Republisher.republish_document_type(args.document_type)
  end

  desc "republish a single document (locale defaults to 'en')"
  task :one, %i[content_id locale] => :environment do |_, args|
    Republisher.republish_one(args.content_id, args.locale)
  end

  desc "republish many documents (space separated list of content_id:locale strings)"
  task :many, [:content_ids_and_locales] => :environment do |_, args|
    Republisher.republish_many(
      args.content_ids_and_locales.split(" ")
        .map { |id_and_locale| id_and_locale.split(":") },
    )
  end
end
