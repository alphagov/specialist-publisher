class FacetInputComponent::SingleSelectComponent < ViewComponent::Base
  include ErrorsHelper

  def initialize(document, document_type, facet_key, facet_name, allowed_values)
    @document = document
    @document_type = document_type
    @facet_key = facet_key
    @facet_name = facet_name
    @allowed_values = allowed_values
    @options = select_options
    @error_message = errors_for_input(document.errors, facet_key)
  end

  def select_options
    selected_value = @document.send(@facet_key)

    @allowed_values.map do |item|
      {
        text: item["label"],
        value: item["value"],
        selected: item["value"] == selected_value,
      }
    end
  end
end
