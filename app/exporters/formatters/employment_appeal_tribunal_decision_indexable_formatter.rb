require "formatters/abstract_specialist_document_indexable_formatter"

class EmploymentAppealTribunalDecisionIndexableFormatter < AbstractSpecialistDocumentIndexableFormatter
  def type
    "employment_appeal_tribunal_decision"
  end

private
  def extra_attributes
    {
      indexable_content: "#{entity.hidden_indexable_content}\n#{entity.body}".strip,
      tribunal_decision_categories: entity.tribunal_decision_categories,
      tribunal_decision_categories_name: expand_value(:tribunal_decision_categories),
      tribunal_decision_decision_date: entity.tribunal_decision_decision_date,
      tribunal_decision_landmark: entity.tribunal_decision_landmark,
      tribunal_decision_landmark_name: expand_value(:tribunal_decision_landmark).first,
      tribunal_decision_sub_categories: entity.tribunal_decision_sub_categories,
      tribunal_decision_sub_categories_name: expand_value(:tribunal_decision_sub_categories),
    }
  end

  def organisation_slugs
    ["employment-appeal-tribunal"]
  end
end
