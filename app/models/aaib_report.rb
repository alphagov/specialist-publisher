require "document_metadata_decorator"

class AaibReport < DocumentMetadataDecorator
  set_extra_field_names [
    :date_of_occurrence,
    :aircraft_category,
    :report_type,
    :location,
    :aircraft_type,
    :registration,
  ]
end
