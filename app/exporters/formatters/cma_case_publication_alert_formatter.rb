require "formatters/abstract_document_publication_alert_formatter"

class CmaCasePublicationAlertFormatter < AbstractDocumentPublicationAlertFormatter

private
  def human_document_type
    "Competition and Markets Authority cases"
  end

  def document_noun
    "case"
  end
end
