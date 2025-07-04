class FacetInputComponent::OrganisationSingleSelectWithSearchComponent < ViewComponent::Base
  include ErrorsHelper
  include OrganisationsHelper

  def initialize(document, document_type, facet_key, facet_name, selected_organisation_content_id)
    @document = document
    @document_type = document_type
    @facet_key = facet_key
    @facet_name = facet_name
    @error_items = errors_for(document.errors, facet_key)
    @options = organisation_select_options(selected_organisation_content_id)
  end
end
