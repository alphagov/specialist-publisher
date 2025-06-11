class FacetInputComponent < ViewComponent::Base
  def initialize(document, facet_config, label_override = nil)
    @document = document
    @document_type = document.document_type.to_sym
    @facet_type = facet_config["type"].to_sym
    @facet_key = facet_config["key"].to_sym
    @facet_name = label_override || facet_config["name"]
    @allowed_values = facet_config["allowed_values"]
    input_properties = facet_config["specialist_publisher_properties"]
    @facet_select_type = input_properties["select"]&.to_sym if input_properties
  end

  def call
    if @facet_type == :date
      render DateComponent.new(@document, @document_type, @facet_key, @facet_name)
    elsif !@allowed_values
      render TextAreaComponent.new(@document, @document_type, @facet_key, @facet_name)
    elsif @facet_select_type == :one
      render SingleSelectWithSearchComponent.new(@document, @document_type, @facet_key, @facet_name, @allowed_values)
    elsif @facet_select_type == :multiple
      render MultiSelectWithSearchComponent.new(@document, @document_type, @facet_key, @facet_name, @allowed_values)
    else
      render layout: "shared/specialist_document_form_error", locals: { field: @facet_key }
    end
  end
end
