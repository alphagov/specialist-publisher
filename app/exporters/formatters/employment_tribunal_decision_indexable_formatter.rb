require "formatters/abstract_specialist_document_indexable_formatter"

class EmploymentTribunalDecisionIndexableFormatter < AbstractSpecialistDocumentIndexableFormatter
  def type
    "employment_tribunal_decision"
  end

private
  def extra_attributes
    {
      indexable_content: "#{entity.hidden_indexable_content}\n#{entity.body}".strip,
      tribunal_decision_categories: entity.tribunal_decision_categories,
      tribunal_decision_categories_name: expand_value(:tribunal_decision_categories),
      tribunal_decision_country: entity.tribunal_decision_country,
      tribunal_decision_country_name: expand_value(:tribunal_decision_country).first,
      tribunal_decision_decision_date: entity.tribunal_decision_decision_date,
    }
  end

  def organisation_slugs
    ["employment-tribunal"]
  end
end
