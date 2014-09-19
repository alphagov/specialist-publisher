require "formatters/abstract_document_publication_alert_formatter"

class InternationalDevelopmentFundPublicationAlertFormatter < AbstractDocumentPublicationAlertFormatter

private
  def human_document_type
    "International development funding"
  end

  def document_noun
    "fund"
  end
end
