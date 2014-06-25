require "builders/specialist_document_builder"

class AaibReportBuilder < SpecialistDocumentBuilder

  def call(attrs)
    attrs.merge!(document_type: "aaib_report")
    super(attrs)
  end

end
