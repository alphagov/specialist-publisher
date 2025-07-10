class FacetInputComponent::MultiSelectWithSearchComponent < ViewComponent::Base
  include ErrorsHelper
  include FacetSelectHelper

  def initialize(document, document_type, facet_key, facet_name, allowed_values)
    @document = document
    @document_type = document_type
    @facet_key = facet_key
    @facet_name = facet_name
    @allowed_values = allowed_values
    @error_items = errors_for(document_type, document.errors, facet_key)
    @options = select_options
  end

  def select_options
    selected_values = @document.send(@facet_key)

    select_options = select_options_for_facet(@allowed_values)
    select_options.map do |label, value|
      {
        text: label,
        value: value,
        selected: selected_values&.include?(value),
      }
    end
  end
end
