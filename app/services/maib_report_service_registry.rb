require "abstract_document_service_registry"
require "specialist_publisher_wiring"

class MaibReportServiceRegistry < AbstractDocumentServiceRegistry
private
  def document_repository
    SpecialistPublisherWiring.get(:maib_report_repository)
  end

  def document_builder
    SpecialistPublisherWiring.get(:maib_report_builder)
  end

  def observers
    @observers ||= MaibReportObserversRegistry.new
  end
end
