require "spec_helper"

RSpec.describe FinderLoader do
  before do
    expect(File).to receive(:read).with("lib/documents/schemas/format-1.json")
                      .and_return('{"name":"format-1"}')
    expect(File).to receive(:mtime).with("lib/documents/schemas/format-1.json")
                      .and_return("yesterday")
  end

  describe "#finders" do
    it "returns matching finder data objects" do
      expect(Dir).to receive(:glob).with("lib/documents/schemas/*.json").and_return(%w[
        lib/documents/schemas/format-1.json
        lib/documents/schemas/format-2.json
      ])
      expect(File).to receive(:read).with("lib/documents/schemas/format-2.json")
        .and_return('{"name":"format-2"}')
      expect(File).to receive(:mtime).with("lib/documents/schemas/format-2.json")
        .and_return("today")

      loader = FinderLoader.new
      expect(loader.finders).to match_array([
        {
          file: { "name" => "format-1" },
          timestamp: "yesterday",
        },
        {

          file: { "name" => "format-2" },
          timestamp: "today",
        },
      ])
    end
  end

  describe "#finder" do
    it "returns one matching finder data object" do
      expect(File).to receive(:exist?).with("lib/documents/schemas/format-1.json")
                        .and_return(true)

      loader = FinderLoader.new
      expect(loader.finder("format-1")).to match_array([
        {
          file: { "name" => "format-1" },
          timestamp: "yesterday",
        },
      ])
    end
  end
end
