namespace :rummager do
  desc "Publish all Finders to Rummager"
  task publish_finders: :environment do
    require "finder_loader"
    require "rummager_finder_publisher"

    finder_loader = FinderLoader.new

    begin
      RummagerFinderPublisher.new(finder_loader.finders).call
    rescue GdsApi::HTTPServerError => e
      puts "Error publishing finder: #{e.inspect}"
    end
  end
end
