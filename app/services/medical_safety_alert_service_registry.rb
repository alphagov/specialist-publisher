require "abstract_document_service_registry"
require "specialist_publisher_wiring"

class MedicalSafetyAlertServiceRegistry < AbstractDocumentServiceRegistry
private
  def document_repository
    SpecialistPublisherWiring.get(:medical_safety_alert_repository)
  end

  def document_builder
    SpecialistPublisherWiring.get(:medical_safety_alert_builder)
  end

  def observers
    @observers ||= MedicalSafetyAlertObserversRegistry.new
  end
end
