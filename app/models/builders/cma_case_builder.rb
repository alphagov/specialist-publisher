require "builders/specialist_document_builder"

class CmaCaseBuilder < SpecialistDocumentBuilder

  def call(attrs)
    attrs.merge!(document_type: "cma_case")
    super(attrs)
  end

end
