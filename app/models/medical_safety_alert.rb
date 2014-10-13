require "document_metadata_decorator"

class MedicalSafetyAlert < DocumentMetadataDecorator
  set_extra_field_names [
    :alert_type,
    :issued_date,
    :medical_specialism,
  ]
end
