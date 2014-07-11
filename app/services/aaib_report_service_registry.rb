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
    all_observers = SpecialistPublisherWiring.get(:observers)

    OpenStruct.new(
      creation: all_observers.aaib_report_creation,
      update: [],
      publication: all_observers.aaib_report_publication,
      withdrawal: all_observers.aaib_report_withdrawal,
    )
  end
end
