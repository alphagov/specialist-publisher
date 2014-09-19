require "formatters/abstract_document_publication_alert_formatter"

class DrugSafetyUpdatePublicationAlertFormatter < AbstractDocumentPublicationAlertFormatter

private
  def human_document_type
    "Drug safety update"
  end

  def document_noun
    "update"
  end
end
