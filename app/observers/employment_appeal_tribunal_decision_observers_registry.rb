require "formatters/employment_appeal_tribunal_decision_indexable_formatter"
require "formatters/employment_appeal_tribunal_decision_publication_alert_formatter"
require "markdown_attachment_processor"

class EmploymentAppealTribunalDecisionObserversRegistry < AbstractSpecialistDocumentObserversRegistry

private
  def finder_schema
    SpecialistPublisherWiring.get(:employment_appeal_tribunal_decision_finder_schema)
  end

  def format_document_for_indexing(document)
    EmploymentAppealTribunalDecisionIndexableFormatter.new(
      MarkdownAttachmentProcessor.new(document)
    )
  end

  def publication_alert_formatter(document)
    EmploymentAppealTribunalDecisionPublicationAlertFormatter.new(
      url_maker: url_maker,
      document: document,
    )
  end
end
