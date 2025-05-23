class FacetInputComponent::InputComponent < ViewComponent::Base
  include ErrorsHelper

  def initialize(document, document_type, facet_key, facet_name, input_type)
    @document = document
    @document_type = document_type
    @facet_key = facet_key
    @facet_name = facet_name
    @error_items = errors_for(document.errors, facet_key)
    @type = input_type
  end
end
