class ViewAdapterRegistry
  def for_document(document)
    get(document.document_type).new(document)
  end

private
  VIEW_ADAPTER_MAP = {
    "aaib_report" => AaibReportViewAdapter,
    "asylum_support_decision" => AsylumSupportDecisionViewAdapter,
    "cma_case" => CmaCaseViewAdapter,
    "countryside_stewardship_grant" => CountrysideStewardshipGrantViewAdapter,
    "drug_safety_update" => DrugSafetyUpdateViewAdapter,
    "employment_appeal_tribunal_decision" => EmploymentAppealTribunalDecisionViewAdapter,
    "employment_tribunal_decision" => EmploymentTribunalDecisionViewAdapter,
    "esi_fund" => EsiFundViewAdapter,
    "international_development_fund" => InternationalDevelopmentFundViewAdapter,
    "maib_report" => MaibReportViewAdapter,
    "medical_safety_alert" => MedicalSafetyAlertViewAdapter,
    "raib_report" => RaibReportViewAdapter,
    "tax_tribunal_decision" => TaxTribunalDecisionViewAdapter,
    "utaac_decision" => UtaacDecisionViewAdapter,
    "vehicle_recalls_and_faults_alert" => VehicleRecallsAndFaultsAlertViewAdapter,
  }.freeze

  def get(type)
    VIEW_ADAPTER_MAP.fetch(type)
  end
end
