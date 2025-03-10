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

  describe "#admin_facet_value_from_allowed_values" do
    it "returns a string of main facet labels and values if the facet is not nested" do
      facet_allowed_values = [{
        "label" => "label",
        "value" => "value",
      }]

      expect(admin_facet_value_from_allowed_values(facet_allowed_values, nested_facet: false)).to eq "label {value}"
    end

    it "returns a string of main and sub facet and values if the facet is nested" do
      facet_allowed_values = [
        {
          "label" => "label 1",
          "value" => "value-1",
          "sub_facets" => [
            {
              "label" => "sub label 11",
              "value" => "sub-value-11",
            },
            {
              "label" => "sub label 12",
              "value" => "sub-value-12",
            },
          ],
        },
        {
          "label" => "label 2",
          "value" => "value-2",
          "sub_facets" => [
            {
              "label" => "sub label 21",
              "value" => "sub-value-21",
            },
          ],
        },
      ]

      expect(admin_facet_value_from_allowed_values(facet_allowed_values, nested_facet: true)).to eq "label 1 {value-1}\n- sub label 11 {sub-value-11}\n- sub label 12 {sub-value-12}\n\nlabel 2 {value-2}\n- sub label 21 {sub-value-21}"
    end
  end
end
