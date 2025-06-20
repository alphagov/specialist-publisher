module FacetSelectHelper
  def select_options_for_facet(facet_values)
    facet_values.map { |facet_value|
      facet_value["sub_facets"] ? nested_facet_options(facet_value) : facet_option(facet_value)
    }.reduce([], :concat)
  end

  def admin_facet_value_from_allowed_values(allowed_values, nested_facet:)
    values = allowed_values&.map do |value|
      value_output = "#{value['label']} {#{value['value']}}"
      nested_facet ? "#{value_output}\n#{value['sub_facets'].map { |sub_facet| "- #{sub_facet['label']} {#{sub_facet['value']}}" }&.join("\n")}" : value_output
    end

    nested_facet ? values&.join("\n\n") : values&.join("\n")
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
