namespace :publishing_api do
  desc "Publish all Finders to the Publishing API"
  task publish_finders: :environment do
    require "publishing_api_finder_publisher"
    require "publishing_api_finder_loader"

    finder_loader = PublishingApiFinderLoader.new

    PublishingApiFinderPublisher.new(finder_loader.finders).call
  end

  desc "Find manual by base_path, publish redirect for the manual and any sections it may have"
  task :redirect_manual_and_sections, [:base_path, :destination] => :environment do |_task, args|
    ManualAndSectionsRedirecter.new(
      base_path: args[:base_path],
      destination: args[:destination]
    ).redirect
  end
end
