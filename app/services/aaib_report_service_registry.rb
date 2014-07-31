require "abstract_document_service_registry"
require "specialist_publisher_wiring"

class AaibReportServiceRegistry < AbstractDocumentServiceRegistry
private
  def document_repository
    SpecialistPublisherWiring.get(:aaib_report_repository)
  end

  def document_builder
    SpecialistPublisherWiring.get(:aaib_report_builder)
  end

  def observers
    @observers ||= AaibReportObserversRegistry.new
  end
end
