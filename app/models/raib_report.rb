require "document_metadata_decorator"

class RaibReport < DocumentMetadataDecorator
  set_extra_field_names [
    :date_of_occurrence,
    :report_type,
    :railway_type,
  ]
end
