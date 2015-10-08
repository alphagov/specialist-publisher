require "delegate"
require "validators/date_validator"
require "validators/safe_html_validator"

class TaxTribunalDecisionViewAdapter < DocumentViewAdapter
  attributes = [
    :hidden_indexable_content,
    :tribunal_decision_category,
    :tribunal_decision_decision_date,
  ]

  def self.model_name
    ActiveModel::Name.new(self, nil, "TaxTribunalDecision")
  end

  attributes.each do |attribute_name|
    define_method(attribute_name) do
      delegate_if_document_exists(attribute_name)
    end
  end

private

  def finder_schema
    SpecialistPublisherWiring.get(:tax_tribunal_decision_finder_schema)
  end
end
