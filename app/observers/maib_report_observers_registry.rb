require "formatters/maib_report_publication_alert_formatter"
require "formatters/maib_report_indexable_formatter"
require "markdown_attachment_processor"

class MaibReportObserversRegistry < AbstractSpecialistDocumentObserversRegistry

private
  def finder_schema
    SpecialistPublisherWiring.get(:maib_report_finder_schema)
  end

  def format_document_as_artefact(document)
    MaibReportArtefactFormatter.new(document)
  end

  def format_document_for_indexing(document)
    MaibReportIndexableFormatter.new(
      MarkdownAttachmentProcessor.new(document)
    )
  end

  def publication_alert_formatter(document)
    MaibReportPublicationAlertFormatter.new(
      url_maker: url_maker,
      document: document,
    )
  end
end
