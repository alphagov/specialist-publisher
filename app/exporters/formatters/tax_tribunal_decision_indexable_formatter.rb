require "formatters/abstract_specialist_document_indexable_formatter"

class TaxTribunalDecisionIndexableFormatter < AbstractSpecialistDocumentIndexableFormatter
  def type
    "tax_tribunal_decision"
  end

private
  def extra_attributes
    {
      indexable_content: "#{entity.hidden_indexable_content}\n#{entity.body}".strip,
      tribunal_decision_category: entity.tribunal_decision_category,
      tribunal_decision_category_name: expand_value(:tribunal_decision_category).first,
      tribunal_decision_decision_date: entity.tribunal_decision_decision_date,
    }
  end

  def organisation_slugs
    ["upper-tribunal-tax-and-chancery-chamber"]
  end
end
