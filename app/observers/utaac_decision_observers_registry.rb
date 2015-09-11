require "formatters/utaac_decision_indexable_formatter"
require "formatters/utaac_decision_publication_alert_formatter"
require "markdown_attachment_processor"

class UtaacDecisionObserversRegistry < AbstractSpecialistDocumentObserversRegistry

private
  def finder_schema
    SpecialistPublisherWiring.get(:utaac_decision_finder_schema)
  end

  def format_document_for_indexing(document)
    UtaacDecisionIndexableFormatter.new(
      MarkdownAttachmentProcessor.new(document)
    )
  end

  def publication_alert_formatter(document)
    UtaacDecisionPublicationAlertFormatter.new(
      url_maker: url_maker,
      document: document,
    )
  end
end
