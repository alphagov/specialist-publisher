require "formatters/abstract_specialist_document_indexable_formatter"

class UtaacDecisionIndexableFormatter < AbstractSpecialistDocumentIndexableFormatter
  def type
    "utaac_decision"
  end

private
  def extra_attributes
    {
      indexable_content: "#{entity.hidden_indexable_content}\n#{entity.body}".strip,
      tribunal_decision_category: entity.tribunal_decision_category,
      tribunal_decision_category_name: expand_value(:tribunal_decision_category).first,
      tribunal_decision_decision_date: entity.tribunal_decision_decision_date,
      tribunal_decision_judges: entity.tribunal_decision_judges,
      tribunal_decision_judges_name: expand_value(:tribunal_decision_judges),
      tribunal_decision_sub_category: entity.tribunal_decision_sub_category.first,
      tribunal_decision_sub_category_name: expand_value(:tribunal_decision_sub_category).first,
    }
  end

  def organisation_slugs
    ["upper-tribunal-administrative-appeals-chamber"]
  end
end
