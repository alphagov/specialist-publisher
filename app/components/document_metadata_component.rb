class DocumentMetadataComponent < ViewComponent::Base
  def initialize(document:)
    @document = document
  end

  def list_facets
    @document.humanized_attributes.inject([]) { |facet_list, (label, values)|
      facet_list << [tag.dt(label).html_safe, "\n", facet_value(values).html_safe]
    }.join.html_safe
  end

  def list_associated_organisations
    @document.organisations.map { |org|
      tag.dd(helpers.organisation_name(org))
    }.join.html_safe
  end

  def publication_state
    content_tag(:span, helpers.state_for_frontend(@document), class: helpers.classes_for_frontend(@document))
  end

private

  def facet_value(values)
    return tag.dd(tag.time(values.to_fs(:govuk_date))) if values.is_a?(Time)

    Array(values).map { |value|
      tag.dd(truncate(value.to_s, length: 140))
    }.join
  end
end
