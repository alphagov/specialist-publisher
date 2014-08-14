require "document_metadata_decorator"

class DrugSafetyUpdate < DocumentMetadataDecorator
  set_extra_field_names [
    :therapeutic_area
  ]
end
