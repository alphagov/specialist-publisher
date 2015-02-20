require "formatters/raib_report_publication_alert_formatter"
require "formatters/raib_report_indexable_formatter"
require "markdown_attachment_processor"
require "rummager_indexer"

class RaibReportObserversRegistry < AbstractSpecialistDocumentObserversRegistry

private
  def content_api_exporter
    SpecialistPublisherWiring.get(:raib_report_content_api_exporter)
  end

  def panopticon_exporter
    SpecialistPublisherWiring.get(:raib_report_panopticon_registerer)
  end

  def rummager_withdrawer
    ->(document) {
      RummagerIndexer.new.delete(
        RaibReportIndexableFormatter.new(
          MarkdownAttachmentProcessor.new(document)
        )
      )
    }
  end

  def rummager_exporter
    ->(document) {
      RummagerIndexer.new.add(
        RaibReportIndexableFormatter.new(
          MarkdownAttachmentProcessor.new(document)
        )
      )
    }
  end

  def publication_alert_formatter(document)
    RaibReportPublicationAlertFormatter.new(
      url_maker: url_maker,
      document: document,
    )
  end
end
