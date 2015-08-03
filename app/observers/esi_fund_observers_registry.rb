require "formatters/esi_fund_indexable_formatter"
require "formatters/esi_fund_publication_alert_formatter"
require "markdown_attachment_processor"

class EsiFundObserversRegistry < AbstractSpecialistDocumentObserversRegistry

private
  def format_document_for_indexing(document)
    EsiFundIndexableFormatter.new(
      MarkdownAttachmentProcessor.new(document)
    )
  end

  def publication_alert_formatter(document)
    EsiFundPublicationAlertFormatter.new(
      url_maker: url_maker,
      document: document,
    )
  end
end
