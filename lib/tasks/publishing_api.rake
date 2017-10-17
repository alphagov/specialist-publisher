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

  desc "Publish special routes"
  task publish_special_routes: :environment do
    logger = Logger.new(STDOUT)

    publisher = SpecialRoutePublisher.new(
      logger: logger,
      publishing_api: Services.publishing_api
    )

    SpecialRoutePublisher.routes.each do |route|
      publisher.publish(route)
    end
  end
end
