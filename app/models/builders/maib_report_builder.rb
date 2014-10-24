require "builders/specialist_document_builder"

class MaibReportBuilder < SpecialistDocumentBuilder

  def call(attrs)
    attrs.merge!(document_type: "maib_report")
    super(attrs)
  end

end
