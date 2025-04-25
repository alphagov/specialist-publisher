class FacetInputComponent::SingleSelectComponent < ViewComponent::Base
  def initialize(document, document_type, facet_key, facet_name, allowed_values)
    @document = document
    @document_type = document_type
    @facet_key = facet_key
    @facet_name = facet_name
    @allowed_values = allowed_values
  end
end
