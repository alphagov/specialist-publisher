require "builders/specialist_document_builder"

class DrugSafetyUpdateBuilder < SpecialistDocumentBuilder

  def call(attrs)
    attrs.merge!(document_type: "drug_safety_update")
    super(attrs)
  end

end
