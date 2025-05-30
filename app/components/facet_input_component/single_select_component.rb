class FacetInputComponent::SingleSelectComponent < ViewComponent::Base
  include ErrorsHelper

  def initialize(document, document_type, facet_key, facet_name, allowed_values, allow_blank_option: true)
    @document = document
    @document_type = document_type
    @facet_key = facet_key
    @facet_name = facet_name
    allowed_values_to_options = allowed_values.map do |item|
      {
        text: item["label"],
        value: item["value"],
        selected: item["value"] == @document.send(@facet_key),
      }
    end
    @options = allow_blank_option ? [{}] + allowed_values_to_options : allowed_values_to_options
    @error_message = errors_for_input(document.errors, facet_key)
  end
end
