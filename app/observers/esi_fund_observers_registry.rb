require "formatters/esi_fund_publication_alert_formatter"
require "formatters/esi_fund_indexable_formatter"
require "markdown_attachment_processor"
require "rummager_indexer"

class EsiFundObserversRegistry < AbstractSpecialistDocumentObserversRegistry

  private
  def panopticon_exporter
    SpecialistPublisherWiring.get(:esi_fund_panopticon_registerer)
  end

  def content_api_exporter
    SpecialistPublisherWiring.get(:esi_fund_content_api_exporter)
  end

  def rummager_exporter
    ->(document) {
      RummagerIndexer.new.add(
        EsiFundIndexableFormatter.new(
          MarkdownAttachmentProcessor.new(document)
        )
      )
    }
  end

  def rummager_withdrawer
    ->(document) {
      RummagerIndexer.new.delete(
        EsiFundIndexableFormatter.new(
          MarkdownAttachmentProcessor.new(document)
        )
      )
    }
  end

  def content_api_withdrawer
    SpecialistPublisherWiring.get(:specialist_document_content_api_withdrawer)
  end

  def publication_alert_formatter(document)
    EsiFundPublicationAlertFormatter.new(
      url_maker: url_maker,
      document: document,
    )
  end
end
