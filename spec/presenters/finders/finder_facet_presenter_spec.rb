require "spec_helper"

RSpec.describe FinderFacetPresenter do
  describe "#to_json" do
    it "removes facets that should not be included in the finder content item" do
      facets = [
        { "bar" => "baz" },
        {
          "foo" => "bar",
          "specialist_publisher_properties" => {
            "omit_from_finder_content_item" => true,
          },
        },
      ]

      keys = FinderFacetPresenter.new(facets).to_json.map(&:keys).flatten
      expect(keys).to include("bar")
      expect(keys).to_not include("foo")
    end

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

      presented_facets = FinderFacetPresenter.new(facets).to_json
      expect(presented_facets).to eq(facets_without_specialist_publisher_properties)
    end
  end
end
