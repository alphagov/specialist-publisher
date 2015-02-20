require "formatters/cma_case_publication_alert_formatter"
require "formatters/cma_case_indexable_formatter"
require "markdown_attachment_processor"
require "rummager_indexer"

class CmaCaseObserversRegistry < AbstractSpecialistDocumentObserversRegistry

private
  def panopticon_exporter
    SpecialistPublisherWiring.get(:cma_case_panopticon_registerer)
  end

  def content_api_exporter
    SpecialistPublisherWiring.get(:cma_case_content_api_exporter)
  end

  def rummager_exporter
    ->(document) {
      RummagerIndexer.new.add(
        CmaCaseIndexableFormatter.new(
          MarkdownAttachmentProcessor.new(document)
        )
      )
    }
  end

  def rummager_withdrawer
    ->(document) {
      RummagerIndexer.new.delete(
        CmaCaseIndexableFormatter.new(
          MarkdownAttachmentProcessor.new(document)
        )
      )
    }
  end

  def publication_alert_formatter(document)
    CmaCasePublicationAlertFormatter.new(
      url_maker: url_maker,
      document: document,
    )
  end
end
