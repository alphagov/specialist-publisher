require "formatters/aaib_report_publication_alert_formatter"
require "formatters/aaib_report_indexable_formatter"
require "markdown_attachment_processor"

class AaibReportObserversRegistry < AbstractSpecialistDocumentObserversRegistry

private
  def finder_schema
    SpecialistPublisherWiring.get(:aaib_report_finder_schema)
  end

  def format_document_as_artefact(document)
    AaibReportArtefactFormatter.new(document)
  end

  def format_document_for_indexing(document)
    AaibReportIndexableFormatter.new(
      MarkdownAttachmentProcessor.new(document)
    )
  end

  def publication_alert_formatter(document)
    AaibReportPublicationAlertFormatter.new(
      url_maker: url_maker,
      document: document,
    )
  end
end
