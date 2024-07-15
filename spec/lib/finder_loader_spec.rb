require "spec_helper"

RSpec.describe FinderLoader do
  before do
    expect(File).to receive(:read).with("lib/documents/schemas/format-1.json")
                      .and_return('{"name":"format-1"}')
    expect(File).to receive(:mtime).with("lib/documents/schemas/format-1.json")
                      .and_return("yesterday")
  end

  describe "#finders" do
    it "returns data objects for all finders by default" do
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

    it "returns data objects only for 'pre-production' finders when `pre_production_only: true` is passed" do
      stubbed_format_file = "lib/documents/schemas/format-pre-production.json"
      expect(File).to receive(:read).with(stubbed_format_file)
        .and_return('{"name":"other-format", "pre_production": true}')
      expect(File).to receive(:mtime).with(stubbed_format_file)
        .and_return("today")

      expect(Dir).to receive(:glob).with("lib/documents/schemas/*.json").and_return([
        "lib/documents/schemas/format-1.json",
        stubbed_format_file,
      ])

      loader = FinderLoader.new
      expect(loader.finders(pre_production_only: true)).to match_array([
        {
          file: { "name" => "other-format", "pre_production" => true },
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
