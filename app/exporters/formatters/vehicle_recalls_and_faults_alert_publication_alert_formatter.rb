require "formatters/abstract_document_publication_alert_formatter"

class VehicleRecallsAndFaultsAlertPublicationAlertFormatter < AbstractDocumentPublicationAlertFormatter
  def name
    "Vehicle recalls and faults"
  end

private

  def document_noun
    "alert"
  end
end
