require "formatters/abstract_document_publication_alert_formatter"

class CmaCasePublicationAlertFormatter < AbstractDocumentPublicationAlertFormatter

  def name
    "Competition and Markets Authority cases"
  end

private
  def document_noun
    "case"
  end
end
