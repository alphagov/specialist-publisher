class DocumentMetadataComponent < ViewComponent::Base
  include OrganisationsHelper
  include StateHelper

  def initialize(document:)
    @document = document
  end

  def metadata_items
    metadata_items = []

    metadata_items.concat(facet_metadata)
    metadata_items.concat(organisations_metadata) if @document.class.has_organisations?
    metadata_items.concat(publication_state)

    metadata_items
  end

private

  def facet_metadata
    @document.humanized_attributes.map do |label, values|
      {
        field: label,
        value: facet_value(values),
      }
    end
  end

  def organisations_metadata
    [{
      field: "Publishing organisation",
      value: organisation_name(@document.primary_publishing_organisation),
    },
     {
       field: "Other associated organisations",
       value: associated_organisations,
     }]
  end

  def publication_state
    [{
      field: "Bulk published",
      value: @document.bulk_published,
    },
     {
       field: "Publication state",
       value: tag.span(state_for_frontend(@document).humanize, class: design_system_classes_for_frontend(@document)),
     }]
  end

  def facet_value(values)
    return values.strftime("%-d %B %Y") if values.is_a?(Date)

    Array(values).map { |value| truncate(value.to_s, length: 140) }.join("<br>").html_safe
  end

  def associated_organisations
    @document.organisations.map { |org|
      organisation_name(org)
    }.join("<br>").html_safe
  end
end
