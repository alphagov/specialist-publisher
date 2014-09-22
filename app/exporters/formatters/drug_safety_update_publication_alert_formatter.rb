require "formatters/abstract_document_publication_alert_formatter"

class DrugSafetyUpdatePublicationAlertFormatter < AbstractDocumentPublicationAlertFormatter

  def name
    "Drug safety update"
  end

private
  def document_noun
    "update"
  end
end
