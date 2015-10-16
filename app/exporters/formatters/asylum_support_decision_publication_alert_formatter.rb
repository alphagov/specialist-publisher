require "formatters/abstract_document_publication_alert_formatter"

class AsylumSupportDecisionPublicationAlertFormatter < AbstractDocumentPublicationAlertFormatter

  def name
    "Asylum support tribunal decisions"
  end

private
  def document_noun
    "decision"
  end
end
