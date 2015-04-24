require "formatters/abstract_specialist_document_indexable_formatter"

class VehicleRecallsAndFaultsAlertIndexableFormatter < AbstractSpecialistDocumentIndexableFormatter
  def type
    "vehicle_recalls_and_faults_alert"
  end

private

  def extra_attributes
    {
      issue_date: entity.issue_date
    }
  end

  def organisation_slugs
    []
  end
end
