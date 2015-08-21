require "formatters/asylum_support_decision_indexable_formatter"
require "formatters/asylum_support_decision_publication_alert_formatter"
require "markdown_attachment_processor"

class AsylumSupportDecisionObserversRegistry < AbstractSpecialistDocumentObserversRegistry

private
  def finder_schema
    SpecialistPublisherWiring.get(:asylum_support_decision_finder_schema)
  end

  def format_document_for_indexing(document)
    AsylumSupportDecisionIndexableFormatter.new(
      MarkdownAttachmentProcessor.new(document)
    )
  end

  def publication_alert_formatter(document)
    AsylumSupportDecisionPublicationAlertFormatter.new(
      url_maker: url_maker,
      document: document,
    )
  end
end
