class FacetInputComponent::MultiSelectWithSearchComponent < ViewComponent::Base
  include ErrorsHelper

  def initialize(document, document_type, facet_key, facet_name, allowed_values)
    @document = document
    @document_type = document_type
    @facet_key = facet_key
    @facet_name = facet_name
    @allowed_values = allowed_values
    @error_items = errors_for(@document.errors, @facet_key)
    @options = select_options
  end

  def select_options
    selected_values = @document.send(@facet_key)

    @allowed_values.map do |item|
      {
        text: item["label"],
        value: item["value"],
        selected: selected_values&.include?(item["value"]),
      }
    end
  end
end
