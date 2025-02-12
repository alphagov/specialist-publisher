module FacetSelectHelper
  def options_for(form, facet_name)
    form.object.allowed_values(facet_name).map do |value|
      [
        value.fetch("label", ""),
        value.fetch("value", ""),
      ]
    end
  end
end
