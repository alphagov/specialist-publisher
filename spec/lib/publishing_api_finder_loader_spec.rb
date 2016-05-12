require "spec_helper"
require "publishing_api_finder_loader"

RSpec.describe PublishingApiFinderLoader do
  before do
    expect(Dir).to receive(:glob).with("lib/documents/schemas/*.json").and_return(%w{
      lib/documents/schemas/format-1.json
      lib/documents/schemas/format-2.json
    })
  end

  it "returns matching finder data objects" do
    expect(File).to receive(:read).with("lib/documents/schemas/format-1.json")
      .and_return('{"name":"format-1"}')
    expect(File).to receive(:read).with("lib/documents/schemas/format-2.json")
      .and_return('{"name":"format-2"}')

    expect(File).to receive(:mtime).with("lib/documents/schemas/format-1.json")
      .and_return("yesterday")
    expect(File).to receive(:mtime).with("lib/documents/schemas/format-2.json")
      .and_return("today")

    loader = PublishingApiFinderLoader.new
    expect(loader.finders).to match_array([
      {
        file: { "name" => "format-1" },
        timestamp: "yesterday"
      },
      {

        file: { "name" => "format-2" },
        timestamp: "today"
      }
    ])
  end
end
