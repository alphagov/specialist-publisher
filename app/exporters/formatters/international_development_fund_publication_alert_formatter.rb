require "formatters/abstract_document_publication_alert_formatter"

class InternationalDevelopmentFundPublicationAlertFormatter < AbstractDocumentPublicationAlertFormatter

  def name
    "International development funding"
  end

private
  def document_noun
    "fund"
  end
end
