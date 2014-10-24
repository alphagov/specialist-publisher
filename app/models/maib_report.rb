require "document_metadata_decorator"

class MaibReport < DocumentMetadataDecorator
  set_extra_field_names [
    :date_of_occurrence,
    :report_type,
    :vessel_type,
  ]
end
