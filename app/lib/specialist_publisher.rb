module SpecialistPublisher
  extend self

  def attachment_services(document_type)
    AbstractAttachmentServiceRegistry.new(
      repository: document_repositories.for_type(document_type)
    )
  end

  def document_services(document_type)
    AbstractDocumentServiceRegistry.new(
      repository: document_repositories.for_type(document_type),
      builder: SpecialistPublisherWiring.get("#{document_type}_builder".to_sym),
      observers: observer_registry(document_type),
    )
  end

  def view_adapter(document)
    view_adapters.for_document(document)
  end
private

  def view_adapters
    SpecialistPublisherWiring.get(:view_adapter_registry)
  end

  def document_repositories
    SpecialistPublisherWiring.get(:repository_registry)
  end

  def observer_registry(document_type)
    {
      "aaib_report" => AaibReportObserversRegistry,
      "cma_case" => CmaCaseObserversRegistry,
      "drug_safety_update" => DrugSafetyUpdateObserversRegistry,
      "international_development_fund" => InternationalDevelopmentFundObserversRegistry,
      "maib_report" => MaibReportObserversRegistry,
      "medical_safety_alert" => MedicalSafetyAlertObserversRegistry,
    }.fetch(document_type).new
  end
end
