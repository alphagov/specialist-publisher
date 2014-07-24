require "builders/specialist_document_builder"

class InternationalDevelopmentFundBuilder < SpecialistDocumentBuilder

  def call(attrs)
    attrs.merge!(document_type: "international_development_fund")
    super(attrs)
  end

end
