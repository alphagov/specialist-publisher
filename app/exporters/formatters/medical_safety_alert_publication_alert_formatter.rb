require "formatters/abstract_document_publication_alert_formatter"

class MedicalSafetyAlertPublicationAlertFormatter < AbstractDocumentPublicationAlertFormatter

private
  def human_document_type
    "Alerts and recalls for drugs and medical devices"
  end

  def document_noun
    "alert"
  end
end
