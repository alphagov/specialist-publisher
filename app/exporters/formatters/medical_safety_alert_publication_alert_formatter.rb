require "formatters/abstract_document_publication_alert_formatter"

class MedicalSafetyAlertPublicationAlertFormatter < AbstractDocumentPublicationAlertFormatter

  def name
    "Alerts and recalls for drugs and medical devices"
  end

private
  def document_noun
    "alert"
  end
end
