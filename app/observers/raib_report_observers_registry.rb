require "formatters/raib_report_artefact_formatter"
require "formatters/raib_report_indexable_formatter"
require "formatters/raib_report_publication_alert_formatter"
require "markdown_attachment_processor"

class RaibReportObserversRegistry < AbstractSpecialistDocumentObserversRegistry

private
  def finder_schema
    SpecialistPublisherWiring.get(:raib_report_finder_schema)
  end

  def format_document_as_artefact(document)
    RaibReportArtefactFormatter.new(document)
  end

  def format_document_for_indexing(document)
    RaibReportIndexableFormatter.new(
      MarkdownAttachmentProcessor.new(document)
    )
  end

  def publication_alert_formatter(document)
    RaibReportPublicationAlertFormatter.new(
      url_maker: url_maker,
      document: document,
    )
  end
end
