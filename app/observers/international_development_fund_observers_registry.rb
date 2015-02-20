require "formatters/international_development_fund_publication_alert_formatter"
require "formatters/international_development_fund_indexable_formatter"
require "markdown_attachment_processor"
require "rummager_indexer"

class InternationalDevelopmentFundObserversRegistry < AbstractSpecialistDocumentObserversRegistry

private
  def panopticon_exporter
    SpecialistPublisherWiring.get(:international_development_fund_panopticon_registerer)
  end

  def content_api_exporter
    SpecialistPublisherWiring.get(:international_development_fund_content_api_exporter)
  end

  def rummager_exporter
    ->(document) {
      RummagerIndexer.new.add(
        InternationalDevelopmentFundIndexableFormatter.new(
          MarkdownAttachmentProcessor.new(document)
        )
      )
    }
  end

  def rummager_withdrawer
    ->(document) {
      RummagerIndexer.new.delete(
        InternationalDevelopmentFundIndexableFormatter.new(
          MarkdownAttachmentProcessor.new(document)
        )
      )
    }
  end

  def content_api_withdrawer
    SpecialistPublisherWiring.get(:specialist_document_content_api_withdrawer)
  end

  def publication_alert_formatter(document)
    InternationalDevelopmentFundPublicationAlertFormatter.new(
      url_maker: url_maker,
      document: document,
    )
  end
end
