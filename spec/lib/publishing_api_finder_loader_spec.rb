require "spec_helper"
require "publishing_api_finder_loader"

describe PublishingApiFinderLoader do
  before do
    expect(Dir).to receive(:glob).with("finders/metadata/*.json").and_return(%w{
      finders/metadata/matching-finder-1.json
      finders/metadata/matching-finder-2.json
      finders/metadata/unmatching-metadata.json
    })
    expect(Dir).to receive(:glob).with("finders/schemas/*.json").and_return(%w{
      finders/schemas/matching-finder-1.json
      finders/schemas/matching-finder-2.json
      finders/schemas/unmatching-schema.json
    })
  end

  it "returns metadata files missing matching schemas" do
    loader = PublishingApiFinderLoader.new("finders")
    expect(loader.metadata_files_missing_schema).to match_array(["unmatching-metadata.json"])
  end

  it "returns schema files missing matching metadata" do
    loader = PublishingApiFinderLoader.new("finders")
    expect(loader.schema_files_missing_metadata).to match_array(["unmatching-schema.json"])
  end

  it "returns matching finder data objects" do
    expect(File).to receive(:read).with("finders/metadata/matching-finder-1.json")
      .and_return('{"name":"finder-metadata-1"}')
    expect(File).to receive(:read).with("finders/metadata/matching-finder-2.json")
      .and_return('{"name":"finder-metadata-2"}')
    expect(File).to receive(:read).with("finders/schemas/matching-finder-1.json")
      .and_return('{"name":"finder-schema-1"}')
    expect(File).to receive(:read).with("finders/schemas/matching-finder-2.json")
      .and_return('{"name":"finder-schema-2"}')

    expect(File).to receive(:mtime).with("finders/metadata/matching-finder-1.json")
      .and_return("yesterday")
    expect(File).to receive(:mtime).with("finders/metadata/matching-finder-2.json")
      .and_return("today")

    loader = PublishingApiFinderLoader.new("finders")
    expect(loader.finders).to match_array([
      {
        metadata: { "name" => "finder-metadata-1" },
        schema: { "name" => "finder-schema-1" },
        timestamp: "yesterday"
      },
      {
        metadata: { "name" => "finder-metadata-2" },
        schema: { "name" => "finder-schema-2" },
        timestamp: "today"
      }
    ])
  end
end
