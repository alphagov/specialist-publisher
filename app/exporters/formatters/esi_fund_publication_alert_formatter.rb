require "formatters/abstract_document_publication_alert_formatter"

class EsiFundPublicationAlertFormatter < AbstractDocumentPublicationAlertFormatter

  def name
    "European Structural and Investment Funds"
  end

  def format
    "european_structural_investment_fund"
  end

private
  def document_noun
    "fund"
  end
end
