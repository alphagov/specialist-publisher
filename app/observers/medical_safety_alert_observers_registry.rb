require "formatters/medical_safety_alert_publication_alert_formatter"
require "formatters/medical_safety_alert_indexable_formatter"
require "markdown_attachment_processor"
require "rummager_indexer"

class MedicalSafetyAlertObserversRegistry < AbstractSpecialistDocumentObserversRegistry

private
  def panopticon_exporter
    SpecialistPublisherWiring.get(:medical_safety_alert_panopticon_registerer)
  end

  def content_api_exporter
    SpecialistPublisherWiring.get(:medical_safety_alert_content_api_exporter)
  end

  def rummager_exporter
    ->(document) {
      RummagerIndexer.new.add(
        MedicalSafetyAlertIndexableFormatter.new(
          MarkdownAttachmentProcessor.new(document)
        )
      )
    }
  end

  def rummager_withdrawer
    ->(document) {
      RummagerIndexer.new.delete(
        MedicalSafetyAlertIndexableFormatter.new(
          MarkdownAttachmentProcessor.new(document)
        )
      )
    }
  end

  def publication_alert_formatter(document)
    MedicalSafetyAlertPublicationAlertFormatter.new(
      url_maker: url_maker,
      document: document,
    )
  end
end
