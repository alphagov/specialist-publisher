require "services"

namespace :publishing_api do
  desc "Publish all Finders to the Publishing API"
  task publish_finders: :environment do
    require "finder_loader"
    require "publishing_api_finder_publisher"

    begin
      PublishingApiFinderPublisher.new(FinderLoader.new.finders).call
    rescue GdsApi::HTTPServerError => e
      puts "Error publishing finder: #{e.inspect}"
    end
  end

  desc "Publish a single Finder to the Publishing API"
  task :publish_finder, [:slug] => :environment do |_, args|
    require "finder_loader"
    require "publishing_api_finder_publisher"

    finder = FinderLoader.new.finder_by_slug(args.slug)
    PublishingApiFinderPublisher.new([finder]).call
  rescue GdsApi::HTTPServerError => e
    puts "Error publishing finder: #{e.inspect}"
  rescue StandardError => e
    puts "Error: #{e.inspect}"
  end

  desc "Patch links for all instances of specified document type in Publishing API."
  task :patch_document_type_links, [:document_type] => :environment do |_, args|
    klass = args.document_type.camelize.constantize
    counter = 0

    AllDocumentsFinder.find_each(klass) do |document|
      document_links_presenter = DocumentLinksPresenter.new(document).to_json
      payload = document_links_presenter.merge(bulk_publishing: true)

      Services.publishing_api.patch_links(document.content_id, payload)
      puts "Links patched for \"#{document.title}\"."
      counter += 1
    end
    puts "Links patched for #{counter} #{args.document_type} documents."
  end

  desc "Publish a Finder to the Publishing API and patch links for all its documents."
  task :publish_finder_and_patch_documents_links, [:schema] => :environment do |_, args|
    Rake::Task["publishing_api:publish_finder"].invoke(args.schema)
    Rake::Task["publishing_api:patch_document_type_links"].invoke(args.schema.singularize)
  end
end
