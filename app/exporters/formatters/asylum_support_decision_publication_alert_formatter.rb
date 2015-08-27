require "formatters/abstract_document_publication_alert_formatter"

class AsylumSupportDecisionPublicationAlertFormatter < AbstractDocumentPublicationAlertFormatter

  def name
    "First-tier Tribunal (Asylum Support) decisions"
  end

private
  def document_noun
    "decision"
  end
end
