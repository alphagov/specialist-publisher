require "formatters/abstract_document_publication_alert_formatter"

class AaibReportPublicationAlertFormatter < AbstractDocumentPublicationAlertFormatter

  def name
    "Air Accidents Investigation Branch reports"
  end

private
  def document_noun
    "report"
  end
end
