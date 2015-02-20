require "formatters/countryside_stewardship_grant_publication_alert_formatter"
require "formatters/countryside_stewardship_grant_indexable_formatter"
require "markdown_attachment_processor"
require "rummager_indexer"

class CountrysideStewardshipGrantObserversRegistry < AbstractSpecialistDocumentObserversRegistry

  private
  def panopticon_exporter
    SpecialistPublisherWiring.get(:countryside_stewardship_grant_panopticon_registerer)
  end

  def content_api_exporter
    SpecialistPublisherWiring.get(:countryside_stewardship_grant_content_api_exporter)
  end

  def rummager_exporter
    ->(document) {
      RummagerIndexer.new.add(
        CountrysideStewardshipGrantIndexableFormatter.new(
          MarkdownAttachmentProcessor.new(document)
        )
      )
    }
  end

  def rummager_withdrawer
    ->(document) {
      RummagerIndexer.new.delete(
        CountrysideStewardshipGrantIndexableFormatter.new(
          MarkdownAttachmentProcessor.new(document)
        )
      )
    }
  end

  def content_api_withdrawer
    SpecialistPublisherWiring.get(:specialist_document_content_api_withdrawer)
  end

  def publication_alert_formatter(document)
    CountrysideStewardshipGrantPublicationAlertFormatter.new(
      url_maker: url_maker,
      document: document,
    )
  end
end
