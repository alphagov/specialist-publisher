require "document_metadata_decorator"

class VehicleRecallsAndFaultsAlert < DocumentMetadataDecorator
  set_extra_field_names [
    :issue_date
  ]
end
