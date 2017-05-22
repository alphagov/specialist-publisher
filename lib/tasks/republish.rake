# At present, these tasks will only republish documents that are in a draft,
# published or republished state.
require 'csv'
require 'services'

namespace :republish do
  desc "republish all documents"
  task all: :environment do
    Republisher.republish_all
  end

  desc "republish all documents for the given document type"
  task :document_type, [:document_type] => :environment do |_, args|
    Republisher.republish_document_type(args.document_type)
  end

  desc "republish a single document"
  task :one, [:content_id] => :environment do |_, args|
    Republisher.republish_one(args.content_id)
  end

  desc "republish many documents (space separated list of content IDs)"
  task :many, [:content_ids] => :environment do |_, args|
    Republisher.republish_many(args.content_ids.split(' '))
  end

  desc "synchronously republish documents to rummager (space separated list of content IDs)"
  task :search, [:content_ids] => :environment do |_, args|
    Republisher.republish_search_sync(args.content_ids.split(' '))
  end
end
