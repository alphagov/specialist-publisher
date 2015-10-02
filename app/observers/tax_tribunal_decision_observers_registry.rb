require "formatters/tax_tribunal_decision_indexable_formatter"
require "formatters/tax_tribunal_decision_publication_alert_formatter"
require "markdown_attachment_processor"

class TaxTribunalDecisionObserversRegistry < AbstractSpecialistDocumentObserversRegistry

private
  def finder_schema
    SpecialistPublisherWiring.get(:tax_tribunal_decision_finder_schema)
  end

  def format_document_for_indexing(document)
    TaxTribunalDecisionIndexableFormatter.new(
      MarkdownAttachmentProcessor.new(document)
    )
  end

  def publication_alert_formatter(document)
    TaxTribunalDecisionPublicationAlertFormatter.new(
      url_maker: url_maker,
      document: document,
    )
  end
end
