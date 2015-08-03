require "formatters/international_development_fund_indexable_formatter"
require "formatters/international_development_fund_publication_alert_formatter"
require "markdown_attachment_processor"

class InternationalDevelopmentFundObserversRegistry < AbstractSpecialistDocumentObserversRegistry

private
  def format_document_for_indexing(document)
    InternationalDevelopmentFundIndexableFormatter.new(
      MarkdownAttachmentProcessor.new(document)
    )
  end

  def publication_alert_formatter(document)
    InternationalDevelopmentFundPublicationAlertFormatter.new(
      url_maker: url_maker,
      document: document,
    )
  end
end
