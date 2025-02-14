module FacetSelectHelper
  def select_options_for_facet(facet_values)
    facet_values.map { |facet_value|
      facet_value["sub_facets"] ? nested_facet_options(facet_value) : facet_option(facet_value)
    }.reduce([], :concat)
  end

private

  def nested_facet_options(facet_value)
    facet_value["sub_facets"].map do |sub_facet|
      label = [facet_value["label"], sub_facet["label"]].join(" - ")
      [label, sub_facet["value"]]
    end
  end

  def facet_option(facet_value)
    [[facet_value["label"], facet_value["value"]]]
  end
end
