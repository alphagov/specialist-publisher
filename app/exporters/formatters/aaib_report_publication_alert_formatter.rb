require "formatters/abstract_document_publication_alert_formatter"

class AaibReportPublicationAlertFormatter < AbstractDocumentPublicationAlertFormatter

private
  def human_document_type
    "Air Accidents Investigation Branch reports"
  end

  def document_noun
    "report"
  end
end
