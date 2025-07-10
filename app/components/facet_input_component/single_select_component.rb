class FacetInputComponent::SingleSelectComponent < ViewComponent::Base
  include ErrorsHelper
  include FacetSelectHelper

  def initialize(document, document_type, facet_key, facet_name, allowed_values)
    @document = document
    @document_type = document_type
    @facet_key = facet_key
    @facet_name = facet_name
    @allowed_values = allowed_values
    @options = select_options
    @error_message = errors_for_input(document_type, document.errors, facet_key)
  end

  def select_options
    selected_value = @document.send(@facet_key)

    select_options = select_options_for_facet(@allowed_values)
    select_options.map do |label, value|
      {
        text: label,
        value: value,
        selected: value == selected_value,
      }
    end
  end
end
