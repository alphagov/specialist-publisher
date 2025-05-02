class FacetInputComponent::DateComponent < ViewComponent::Base
  include ErrorsHelper

  def initialize(document, document_type, facet_key, facet_name)
    @document = document
    @document_type = document_type
    @facet_key = facet_key
    @facet_name = facet_name
    @error_items = errors_for(document.errors, facet_key)
  end
end
