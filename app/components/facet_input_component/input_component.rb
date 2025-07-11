class FacetInputComponent::InputComponent < ViewComponent::Base
  include ErrorsHelper

  def initialize(document, document_type, facet_key, facet_name, input_type = nil)
    @document = document
    @document_type = document_type
    @facet_key = facet_key
    @facet_name = facet_name
    @error_items = errors_for(document_type, document.errors, facet_key)
    @type = input_type || "text"
  end
end
