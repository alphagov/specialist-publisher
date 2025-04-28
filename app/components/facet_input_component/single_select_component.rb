class FacetInputComponent::SingleSelectComponent < ViewComponent::Base
  include ErrorsHelper

  def initialize(document, document_type, facet_key, facet_name, allowed_values)
    @document = document
    @document_type = document_type
    @facet_key = facet_key
    @facet_name = facet_name
    @allowed_values = allowed_values
    @error_message = errors_for_input(document.errors, facet_key)
  end
end
