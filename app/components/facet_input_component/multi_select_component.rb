class FacetInputComponent::MultiSelectComponent < ViewComponent::Base
  include ErrorsHelper

  def initialize(document, document_type, facet_key, facet_name, allowed_values)
    @document = document
    @document_type = document_type
    @facet_key = facet_key
    @facet_name = facet_name
    @allowed_values = allowed_values
  end

  def pre_selected_items
    return [{ fields: template_add_another }] if @document.send(@facet_key).blank?

    items = []
    @document.send(@facet_key).each_with_index do |facet_value, index|
      items << {
        fields: template_add_another(index, facet_value),
      }
    end
    items
  end

  def template_add_another(index = 0, value = nil)
    render("govuk_publishing_components/components/select", {
      id: "#{@facet_key}_#{index}",
      name: "#{@document_type}[#{@facet_key}][]",
      label: "Select a #{@facet_name.downcase}",
      heading_size: "s",
      full_width: true,
      error_message: errors_for_input(@document.errors, @facet_key),
      options: @allowed_values.inject([{}]) do |options, item|
        options << {
          text: item["label"],
          value: item["value"],
          selected: item["value"] == value,
        }
      end,
    })
  end
end
