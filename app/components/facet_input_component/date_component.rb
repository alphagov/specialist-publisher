class FacetInputComponent::DateComponent < ViewComponent::Base
  def initialize(document, document_type, facet_key, facet_name)
    @document = document
    @document_type = document_type
    @facet_key = facet_key
    @facet_name = facet_name
  end
end
