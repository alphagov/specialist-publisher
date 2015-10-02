require "formatters/abstract_document_publication_alert_formatter"

class TaxTribunalDecisionPublicationAlertFormatter < AbstractDocumentPublicationAlertFormatter

  def name
    "Upper Tribunal (Tax and Chancery Chamber)"
  end

private
  def document_noun
    "decision"
  end
end
