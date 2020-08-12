namespace :publishing_api do
  desc "Publish all Finders to the Publishing API"
  task publish_finders: :environment do
    require "finder_loader"
    require "publishing_api_finder_publisher"

    finder_loader = FinderLoader.new

    begin
      PublishingApiFinderPublisher.new(finder_loader.finders).call
    rescue GdsApi::HTTPServerError => e
      puts "Error publishing finder: #{e.inspect}"
    end
  end

  desc "Publish a single Finder to the Publishing API"
  task :publish_finder, [:name] => :environment do |_, args|
    require "finder_loader"
    require "publishing_api_finder_publisher"

    begin
      finder_loader = FinderLoader.new
      finder = finder_loader.finder(args.name)
    rescue StandardError => e
      puts "Error: #{e.inspect}"
    end

    if finder
      begin
        PublishingApiFinderPublisher.new(finder).call
      rescue GdsApi::HTTPServerError => e
        puts "Error publishing finder: #{e.inspect}"
      end
    end
  end

  desc "Send links for all cma cases to Publishing API."
  task patch_cma_case_links: :environment do
    AllDocumentsFinder.find_each(CmaCase) do |cma_case|
      content_id = cma_case.content_id
      payload = {
        primary_publishing_organisation: [cma_case.primary_publishing_organisation],
      }

      Services.publishing_api.patch_links(content_id, links: payload, bulk_publishing: true)
    end
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
end
