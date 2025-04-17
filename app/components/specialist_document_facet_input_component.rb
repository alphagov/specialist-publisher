class SpecialistDocumentFacetInputComponent < ViewComponent::Base
  def initialize(document, finder_schema, facet_config)
    @document = document
    @document_type = finder_schema.filter["format"].to_sym
    @facet_type = facet_config["type"].to_sym
    @facet_key = facet_config["key"].to_sym
    @facet_name = facet_config["name"]
    @allowed_values = facet_config["allowed_values"]
    input_properties = facet_config["specialist_publisher_properties"]
    @facet_select_type = input_properties["select"]&.to_sym if input_properties
  end
end