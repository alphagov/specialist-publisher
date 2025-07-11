class FacetInputComponent::OrganisationSingleSelectWithSearchComponent < ViewComponent::Base
  include ErrorsHelper
  include OrganisationsHelper

  def initialize(document, document_type, facet_key, facet_name, selected_organisation_content_id, has_all_option: false, heading_size: "m")
    @document = document
    @document_type = document_type
    @facet_key = facet_key
    @label = facet_name
    @heading_size = heading_size
    @id = document_type ? "#{document_type}_#{facet_key}" : facet_key.to_s
    @name = document_type ? "#{document_type}[#{facet_key}]" : facet_key
    @error_items = @document ? errors_for(document_type, document.errors, facet_key) : nil
    @options = organisation_single_select_options(selected_organisation_content_id, has_all_option: has_all_option)
  end
end
