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

    it "returns main facet label and value references in the sub-facet structure" do
      facets_from_schema = [{
        "allowed_values" => [
          {
            "label" => "Allowed value 1",
            "value" => "allowed-value-1",
            "sub_facets" => [
              {
                "label" => "Sub facet Value 1",
                "value" => "allowed-value-1-sub-facet-value-1",
              },
              {
                "label" => "Sub facet Value 2",
                "value" => "allowed-value-1-sub-facet-value-2",
              },
            ],
          },
          {
            "label" => "Allowed value 2",
            "value" => "allowed-value-2",
            "sub_facets" => [
              {
                "label" => "Sub facet Value 1",
                "value" => "allowed-value-2-sub-facet-value-1",
              },
            ],
          },
          {
            "label" => "Allowed value 3",
            "value" => "allowed-value-3",
          },
        ],
        "display_as_result_metadata" => true,
        "filterable" => true,
        "key" => "facet_key",
        "name" => "Facet Name",
        "preposition" => "Facet Name",
        "short_name" => "Short Name",
        "sub_facet_key" => "sub_facet_key",
        "sub_facet_name" => "Sub Facet Name",
        "type" => "nested",
      }]
      main_facet_hash = [{
        "allowed_values" => [
          {
            "label" => "Allowed value 1",
            "value" => "allowed-value-1",
            "sub_facets" => [
              {
                "label" => "Sub facet Value 1",
                "value" => "allowed-value-1-sub-facet-value-1",
                "main_facet_label" => "Allowed value 1",
                "main_facet_value" => "allowed-value-1",
              },
              {
                "label" => "Sub facet Value 2",
                "value" => "allowed-value-1-sub-facet-value-2",
                "main_facet_label" => "Allowed value 1",
                "main_facet_value" => "allowed-value-1",
              },
            ],
          },
          {
            "label" => "Allowed value 2",
            "value" => "allowed-value-2",
            "sub_facets" => [
              {
                "label" => "Sub facet Value 1",
                "value" => "allowed-value-2-sub-facet-value-1",
                "main_facet_label" => "Allowed value 2",
                "main_facet_value" => "allowed-value-2",
              },
            ],
          },
          {
            "label" => "Allowed value 3",
            "value" => "allowed-value-3",
          },
        ],
        "display_as_result_metadata" => true,
        "filterable" => true,
        "key" => "facet_key",
        "name" => "Facet Name",
        "preposition" => "Facet Name",
        "short_name" => "Short Name",
        "sub_facet_key" => "sub_facet_key",
        "sub_facet_name" => "Sub Facet Name",
        "type" => "nested",
      }]

      presented_data = FinderFacetPresenter.new(facets_from_schema).to_json
      expect(presented_data).to eq(main_facet_hash)
    end
  end
end
