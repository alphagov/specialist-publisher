require "formatters/employment_tribunal_decision_indexable_formatter"
require "formatters/employment_tribunal_decision_publication_alert_formatter"
require "markdown_attachment_processor"

class EmploymentTribunalDecisionObserversRegistry < AbstractSpecialistDocumentObserversRegistry

private
  def finder_schema
    SpecialistPublisherWiring.get(:employment_tribunal_decision_finder_schema)
  end

  def format_document_for_indexing(document)
    EmploymentTribunalDecisionIndexableFormatter.new(
      MarkdownAttachmentProcessor.new(document)
    )
  end

  def publication_alert_formatter(document)
    EmploymentTribunalDecisionPublicationAlertFormatter.new(
      url_maker: url_maker,
      document: document,
    )
  end
end
