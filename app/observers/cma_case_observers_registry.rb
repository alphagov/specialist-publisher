require "formatters/cma_case_indexable_formatter"
require "formatters/cma_case_publication_alert_formatter"
require "markdown_attachment_processor"

class CmaCaseObserversRegistry < AbstractSpecialistDocumentObserversRegistry

private

  def finder_schema
    SpecialistPublisherWiring.get(:cma_case_finder_schema)
  end

  def format_document_for_indexing(document)
    CmaCaseIndexableFormatter.new(
      MarkdownAttachmentProcessor.new(document)
    )
  end

  def publication_alert_formatter(document)
    CmaCasePublicationAlertFormatter.new(
      url_maker: url_maker,
      document: document,
    )
  end
end
