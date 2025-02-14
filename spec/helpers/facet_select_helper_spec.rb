require "rails_helper"

RSpec.describe FacetSelectHelper, type: :helper do
  describe "#select_options_for_facet" do
    it "returns facet values with no sub-facets for select dropdown" do
      facets = [{
        "label" => "label",
        "value" => "value",
      }]

      expect(select_options_for_facet(facets)).to eq [%w[label value]]
    end

    it "returns facet values with sub-facets as sub-facets only without the parent facet for select dropdown" do
      facets = [
        {
          "label" => "parent",
          "value" => "parent",
          "sub_facets" => [
            {
              "label" => "child 1",
              "value" => "parent-child-1",
            },
            {
              "label" => "child 2",
              "value" => "parent-child-2",
            },
          ],
        },
      ]

      expected_select_dropdown_values = [
        ["parent - child 1", "parent-child-1"],
        ["parent - child 2", "parent-child-2"],
      ]

      expect(select_options_for_facet(facets)).to eq expected_select_dropdown_values
    end

    it "returns a mix of facets with no sub-facets and facets that do for select dropdown" do
      facets = [
        {
          "label" => "label",
          "value" => "value",
        },
        {
          "label" => "parent",
          "value" => "parent",
          "sub_facets" => [
            {
              "label" => "child 1",
              "value" => "parent-child-1",
            },
          ],
        },
      ]

      expected_select_dropdown_values = [
        ["label", "value"],
        ["parent - child 1", "parent-child-1"],
      ]

      expect(select_options_for_facet(facets)).to eq expected_select_dropdown_values
    end
  end
end
