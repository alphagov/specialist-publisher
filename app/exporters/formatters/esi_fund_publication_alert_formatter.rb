require "formatters/abstract_document_publication_alert_formatter"

class EsiFundPublicationAlertFormatter < AbstractDocumentPublicationAlertFormatter

  def name
    "European Structural and Investment Funds"
  end

private
  def document_noun
    "fund"
  end
end
