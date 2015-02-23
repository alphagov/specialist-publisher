require "formatters/drug_safety_update_indexable_formatter"
require "markdown_attachment_processor"

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

  def format_document_as_artefact(document)
    DrugSafetyUpdateArtefactFormatter.new(document)
  end

  def format_document_for_indexing(document)
    DrugSafetyUpdateIndexableFormatter.new(
      MarkdownAttachmentProcessor.new(document)
    )
  end
end
