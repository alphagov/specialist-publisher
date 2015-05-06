require "document_metadata_decorator"

class VehicleRecallsAndFaultsAlert < DocumentMetadataDecorator
  set_extra_field_names [
    :fault_type,
    :faulty_item_type,
    :alert_issue_date,
    :manufacturer,
    :faulty_item_model,
    :serial_number,
    :build_start_date,
    :build_end_date,
  ]
end
