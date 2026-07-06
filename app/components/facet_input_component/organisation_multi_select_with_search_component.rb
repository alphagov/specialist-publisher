class FacetInputComponent::OrganisationMultiSelectWithSearchComponent < ViewComponent::Base
  include ErrorsHelper
  include OrganisationsHelper

  def initialize(document, document_type, facet_key, facet_name)
    @document = document
    @document_type = document_type
    @facet_key = facet_key
    @label = facet_name
    @id = document_type ? "#{document_type}_#{facet_key}" : facet_key.to_s
    @name = document_type ? "#{document_type}[#{facet_key}][]" : "#{facet_key}[]"
    @error_items = errors_for(document_type, document.errors, facet_key)
    @options = select_options
  end

  def select_options
    selected_values = @document.send(@facet_key)

    all_organisations
      .sort_by { |org| org.title.downcase.strip }
      .map do |organisation|
      {
        text: organisation.title,
        value: organisation.content_id,
        selected: selected_values&.include?(organisation.content_id),
      }
    end
  end
end
