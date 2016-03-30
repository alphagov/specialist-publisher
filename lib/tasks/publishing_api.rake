namespace :publishing_api do
  desc "Publish all Finders to the Publishing API"
  task publish_finders: :environment do
    require "publishing_api_finder_publisher"
    require "publishing_api_finder_loader"

    finder_loader = PublishingApiFinderLoader.new

    PublishingApiFinderPublisher.new(finder_loader.finders).call
  end
end
