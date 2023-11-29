require "spec_helper"
require "finder_loader"

RSpec.describe FinderLoader do
  it "returns matching finder data objects" do
    expect(Dir).to receive(:glob).with("lib/documents/schemas/*.json").and_return(%w[
      lib/documents/schemas/format-1.json
      lib/documents/schemas/format-2.json
    ])

    expect(File).to receive(:read).with("lib/documents/schemas/format-1.json")
      .and_return('{"name":"format-1"}')
    expect(File).to receive(:mtime).with("lib/documents/schemas/format-1.json")
      .and_return("yesterday")
    expect(File).to receive(:read).with("lib/documents/schemas/format-2.json")
      .and_return('{"name":"format-2"}')
    expect(File).to receive(:mtime).with("lib/documents/schemas/format-2.json")
      .and_return("today")

    expect(FinderLoader.new.finders).to match_array([
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

  it "returns one matching finder data object by slug" do
    expect(Dir).to receive(:glob).with("lib/documents/schemas/*.json").and_return(%w[
      spec/fixtures/documents/schemas/licence_transactions.json
    ])
    expect(File).to receive(:mtime).with("spec/fixtures/documents/schemas/licence_transactions.json")
                                   .and_return("today")

    loaded_finder = FinderLoader.new.finder_by_slug("find-licences")
    expect(loaded_finder[:file]).to include({ "base_path" => "/find-licences" })
    expect(loaded_finder[:timestamp]).to eq("today")
  end

  it "errors when no finder is found with slug" do
    expect(Dir).to receive(:glob).with("lib/documents/schemas/*.json").and_return(%w[
      spec/fixtures/documents/schemas/licence_transactions.json
    ])

    expect { FinderLoader.new.finder_by_slug("test-slug") }.to raise_error("Could not find any schema with slug: test-slug")
  end
end
