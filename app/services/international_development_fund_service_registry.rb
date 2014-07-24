require "abstract_document_service_registry"
require "specialist_publisher_wiring"
require "international_development_fund_observers_registry"

class InternationalDevelopmentFundServiceRegistry < AbstractDocumentServiceRegistry
private
  def document_repository
    SpecialistPublisherWiring.get(:international_development_fund_repository)
  end

  def document_builder
    SpecialistPublisherWiring.get(:international_development_fund_builder)
  end

  def observers
    @observers ||= InternationalDevelopmentFundObserversRegistry.new
  end
end
