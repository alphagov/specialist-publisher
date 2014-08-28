require "builders/specialist_document_builder"

class MedicalSafetyAlertBuilder < SpecialistDocumentBuilder

  def call(attrs)
    attrs.merge!(document_type: "medical_safety_alert")
    super(attrs)
  end

end
