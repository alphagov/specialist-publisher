class ViewAdapterRegistry
  def for_document(document)
    get(document.document_type).new(document)
  end

  private

  def get(type)
    {
      "aaib_report" => AaibReportViewAdapter,
      "cma_case" => CmaCaseViewAdapter,
      "drug_safety_updates" => DrugSafetyUpdateViewAdapter,
      "international_development_funds" => InternationalDevelopmentFundViewAdapter,
      "medical_safety_alerts" => MedicalSafetyAlertViewAdapter,
    }.fetch(type)
  end
end
