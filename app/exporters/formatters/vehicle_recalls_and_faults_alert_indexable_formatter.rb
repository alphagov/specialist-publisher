require "formatters/abstract_specialist_document_indexable_formatter"

class VehicleRecallsAndFaultsAlertIndexableFormatter < AbstractSpecialistDocumentIndexableFormatter
  def type
    "vehicle_recalls_and_faults_alert"
  end

private

  def extra_attributes
    {
      fault_type: entity.fault_type,
      faulty_item_type: entity.faulty_item_type,
      manufacturer: entity.manufacturer,
      alert_issue_date: entity.alert_issue_date,
      faulty_item_model: entity.faulty_item_model,
      serial_number: entity.serial_number,
      build_start_date: entity.build_start_date,
      build_end_date: entity.build_end_date,
    }
  end

  def organisation_slugs
    ["driver-and-vehicle-standards-agency"]
  end
end
