namespace :rummager do
  desc "Publish all Finders to Rummager"
  task publish_finders: :environment do
    require "rummager_finder_publisher"

    require "multi_json"

    schemas = Dir.glob("lib/documents/schemas/*.yml").map do |file_path|
      {
        file: YAML.load_file(file_path),
        timestamp: File.mtime(file_path)
      }
    end

    RummagerFinderPublisher.new(schemas).call
  end
end
