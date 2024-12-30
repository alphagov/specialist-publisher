require "spec_helper"

RSpec.describe FinderContentItemPresenter do
  describe "#to_json" do
    Dir["lib/documents/schemas/*.json"].each do |file|
      it "is valid against the #{file} content schemas" do
        read_file = File.read(file)
        payload = JSON.parse(read_file)

        presenter = FinderContentItemPresenter.new(
          payload, Time.zone.parse("2016-01-01T00:00:00-00:00")
        )

        presented_data = presenter.to_json

        expect(presented_data[:schema_name]).to eq("finder")
        expect(presented_data).to be_valid_against_publisher_schema("finder")
      end
    end
  end

  describe ".facets_without_specialist_publisher_properties" do
    it "strips specialist_publisher_properties hash if present" do
      facets = [
        {
          "foo" => "bar",
          "specialist_publisher_properties" => {
            "select" => "one",
          },
        },
      ]
      facets_without_specialist_publisher_properties = [
        { "foo" => "bar" },
      ]

      expect(FinderContentItemPresenter.facets_without_specialist_publisher_properties(facets))
        .to eq(facets_without_specialist_publisher_properties)
    end
  end
end
