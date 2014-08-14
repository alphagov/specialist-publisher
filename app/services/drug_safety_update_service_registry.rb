require "abstract_document_service_registry"
require "specialist_publisher_wiring"

class DrugSafetyUpdateServiceRegistry < AbstractDocumentServiceRegistry
private
  def document_repository
    SpecialistPublisherWiring.get(:drug_safety_update_repository)
  end

  def document_builder
    SpecialistPublisherWiring.get(:drug_safety_update_builder)
  end

  def observers
    @observers ||= DrugSafetyUpdateObserversRegistry.new
  end
end
