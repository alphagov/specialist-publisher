require "abstract_document_service_registry"
require "specialist_publisher_wiring"
require "cma_case_observers_registry"

class CmaCaseServiceRegistry < AbstractDocumentServiceRegistry
private
  def document_repository
    SpecialistPublisherWiring.get(:cma_case_repository)
  end

  def document_builder
    SpecialistPublisherWiring.get(:cma_case_builder)
  end

  def observers
    @observers ||= CmaCaseObserversRegistry.new
  end
end
