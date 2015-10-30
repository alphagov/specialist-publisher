require "formatters/abstract_document_publication_alert_formatter"

class EmploymentAppealTribunalDecisionPublicationAlertFormatter < AbstractDocumentPublicationAlertFormatter

  def name
    "Employment appeal tribunal decisions"
  end

private
  def document_noun
    "decision"
  end
end
