require "abstract_document_service_registry"
require "specialist_publisher_wiring"

class RaibReportServiceRegistry < AbstractDocumentServiceRegistry
private
  def document_repository
    SpecialistPublisherWiring.get(:raib_report_repository)
  end

  def document_builder
    SpecialistPublisherWiring.get(:raib_report_builder)
  end

  def observers
    @observers ||= RaibReportObserversRegistry.new
  end
end
