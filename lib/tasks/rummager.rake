
namespace :rummager do
  desc "Publish all Finders to Rummager"
  task :publish_finders => :environment do
    require "rummager_finder_publisher"

    require "multi_json"

    metadatas = Dir.glob("finders/metadata/**/*.json").map do |file_path|
      {
        file: MultiJson.load(File.read(file_path)),
        timestamp: File.mtime(file_path)
      }
    end

    RummagerFinderPublisher.new(metadatas).call
  end
end
