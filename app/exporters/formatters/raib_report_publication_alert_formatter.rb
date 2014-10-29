require "formatters/abstract_document_publication_alert_formatter"

class RaibReportPublicationAlertFormatter < AbstractDocumentPublicationAlertFormatter

  def name
    "Rail Accident Investigation Branch reports"
  end

private
  def document_noun
    "report"
  end
end
