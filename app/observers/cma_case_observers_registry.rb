require "formatters/cma_case_publication_alert_formatter"
require "formatters/cma_case_indexable_formatter"
require "markdown_attachment_processor"

class CmaCaseObserversRegistry < AbstractSpecialistDocumentObserversRegistry

private
  def format_document_as_artefact(document)
    CmaCaseArtefactFormatter.new(document)
  end

  def content_api_exporter
    SpecialistPublisherWiring.get(:cma_case_content_api_exporter)
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
