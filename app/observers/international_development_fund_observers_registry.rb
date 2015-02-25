require "formatters/international_development_fund_publication_alert_formatter"
require "formatters/international_development_fund_indexable_formatter"
require "markdown_attachment_processor"

class InternationalDevelopmentFundObserversRegistry < AbstractSpecialistDocumentObserversRegistry

private
  def format_document_as_artefact(document)
    InternationalDevelopmentFundArtefactFormatter.new(document)
  end

  def content_api_exporter
    ->(document) {
      SpecialistDocumentDatabaseExporter.new(
        RenderedSpecialistDocument,
        SpecialistPublisherWiring.get(:international_development_fund_renderer),
        finder_schema,
        document,
        PublicationLog,
      ).call
    }
  end

  def finder_schema
    SpecialistPublisherWiring.get(:international_development_fund_finder_schema)
  end

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
