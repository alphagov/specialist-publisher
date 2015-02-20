require "formatters/drug_safety_update_indexable_formatter"
require "markdown_attachment_processor"
require "rummager_indexer"

class DrugSafetyUpdateObserversRegistry < AbstractSpecialistDocumentObserversRegistry
  # Overridden to not send publication alerts -- they're sent manually each month to the list
  def publication
    [
      publication_logger,
      content_api_exporter,
      panopticon_exporter,
      rummager_exporter,
    ]
  end

private
  def content_api_exporter
    SpecialistPublisherWiring.get(:drug_safety_update_content_api_exporter)
  end

  def panopticon_exporter
    SpecialistPublisherWiring.get(:drug_safety_update_panopticon_registerer)
  end

  def rummager_withdrawer
    ->(document) {
      RummagerIndexer.new.delete(
        DrugSafetyUpdateIndexableFormatter.new(
          MarkdownAttachmentProcessor.new(document)
        )
      )
    }
  end

  def rummager_exporter
    ->(document) {
      RummagerIndexer.new.add(
        DrugSafetyUpdateIndexableFormatter.new(
          MarkdownAttachmentProcessor.new(document)
        )
      )
    }
  end
end
