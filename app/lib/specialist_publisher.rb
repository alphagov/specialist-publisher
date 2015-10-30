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

  def document_types
    OBSERVER_MAP.keys
  end

private
  OBSERVER_MAP = {
    "aaib_report" => AaibReportObserversRegistry,
    "asylum_support_decision" => AsylumSupportDecisionObserversRegistry,
    "cma_case" => CmaCaseObserversRegistry,
    "countryside_stewardship_grant" => CountrysideStewardshipGrantObserversRegistry,
    "drug_safety_update" => DrugSafetyUpdateObserversRegistry,
    "employment_appeal_tribunal_decision" => EmploymentAppealTribunalDecisionObserversRegistry,
    "employment_tribunal_decision" => EmploymentTribunalDecisionObserversRegistry,
    "esi_fund" => EsiFundObserversRegistry,
    "international_development_fund" => InternationalDevelopmentFundObserversRegistry,
    "maib_report" => MaibReportObserversRegistry,
    "medical_safety_alert" => MedicalSafetyAlertObserversRegistry,
    "raib_report" => RaibReportObserversRegistry,
    "tax_tribunal_decision" => TaxTribunalDecisionObserversRegistry,
    "utaac_decision" => UtaacDecisionObserversRegistry,
    "vehicle_recalls_and_faults_alert" => VehicleRecallsAndFaultsAlertObserversRegistry,
  }.freeze

  def view_adapters
    SpecialistPublisherWiring.get(:view_adapter_registry)
  end

  def document_repositories
    SpecialistPublisherWiring.get(:repository_registry)
  end

  def observer_registry(document_type)
    OBSERVER_MAP.fetch(document_type).new
  end
end
