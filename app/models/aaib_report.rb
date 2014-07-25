require "document_metadata_decorator"

class AaibReport < DocumentMetadataDecorator
  set_extra_field_names [
    :registration_string,
    :date_of_occurrence,
    :registrations,
    :aircraft_category,
    :report_type,
    :location,
    :aircraft_types,
  ]
end
