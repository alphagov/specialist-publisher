require "formatters/abstract_document_publication_alert_formatter"

class CountrysideStewardshipGrantPublicationAlertFormatter < AbstractDocumentPublicationAlertFormatter

  def name
    "Countryside Stewardship Grants"
  end

  private
  def document_noun
    "grant"
  end
end
