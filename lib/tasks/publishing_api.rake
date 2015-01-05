namespace :publishing_api do
  desc "Publish all Finders to the Publishing API"
  task :publish_finders do
    require "publishing_api_finder_publisher"

    require "multi_json"

    metadata = Dir.glob("finders/metadata/**/*.json").map do |file_path|
      {
        file: MultiJson.load(File.read(file_path)),
        timestamp: File.mtime(file_path)
      }
    end

    schemae = Dir.glob("finders/schemas/**/*.json").map do |file_path|
      {
        file: MultiJson.load(File.read(file_path)),
        timestamp: File.mtime(file_path)
      }
    end

    PublishingApiFinderPublisher.new(metadata, schemae).call
  end
end
