require "formatters/abstract_document_publication_alert_formatter"

class MaibReportPublicationAlertFormatter < AbstractDocumentPublicationAlertFormatter

  def name
    "Marine Accident Investigation Branch reports"
  end

private
  def document_noun
    "report"
  end
end
