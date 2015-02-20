require "formatters/aaib_report_publication_alert_formatter"
require "formatters/aaib_report_indexable_formatter"
require "markdown_attachment_processor"
require "rummager_indexer"

class AaibReportObserversRegistry < AbstractSpecialistDocumentObserversRegistry

private
  def content_api_exporter
    SpecialistPublisherWiring.get(:aaib_report_content_api_exporter)
  end

  def panopticon_exporter
    SpecialistPublisherWiring.get(:aaib_report_panopticon_registerer)
  end

  def rummager_withdrawer
    ->(document) {
      RummagerIndexer.new.delete(
        AaibReportIndexableFormatter.new(
          MarkdownAttachmentProcessor.new(document)
        )
      )
    }
  end

  def rummager_exporter
    ->(document) {
      RummagerIndexer.new.add(
        AaibReportIndexableFormatter.new(
          MarkdownAttachmentProcessor.new(document)
        )
      )
    }
  end

  def content_api_withdrawer
    SpecialistPublisherWiring.get(:specialist_document_content_api_withdrawer)
  end

  def publication_alert_formatter(document)
    AaibReportPublicationAlertFormatter.new(
      url_maker: url_maker,
      document: document,
    )
  end
end
