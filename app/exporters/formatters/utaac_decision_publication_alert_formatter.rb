require "formatters/abstract_document_publication_alert_formatter"

class UtaacDecisionPublicationAlertFormatter < AbstractDocumentPublicationAlertFormatter

  def name
    "Upper Tribunal Administrative Appeals Chamber"
  end

private
  def document_noun
    "decision"
  end
end
