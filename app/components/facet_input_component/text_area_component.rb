class FacetInputComponent::TextAreaComponent < ViewComponent::Base
  include ErrorsHelper

  def initialize(document, document_type, facet_key, facet_name, hint: nil)
    @document = document
    @document_type = document_type
    @facet_key = facet_key
    @facet_name = facet_name
    @error_items = errors_for(document_type, document.errors, facet_key)
    @hint = hint
  end
end
