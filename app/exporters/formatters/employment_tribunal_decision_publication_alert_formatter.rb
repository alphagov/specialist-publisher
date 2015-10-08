require "formatters/abstract_document_publication_alert_formatter"

class EmploymentTribunalDecisionPublicationAlertFormatter < AbstractDocumentPublicationAlertFormatter

  def name
    "Employment tribunal decisions"
  end

private
  def document_noun
    "decision"
  end
end
