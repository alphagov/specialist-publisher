require "delegate"
require "validators/date_validator"
require "validators/safe_html_validator"

class UtaacDecisionViewAdapter < DocumentViewAdapter
  attributes = [
    :hidden_indexable_content,
    :tribunal_decision_category,
    :tribunal_decision_decision_date,
    :tribunal_decision_judges,
    :tribunal_decision_sub_category,
  ]

  def self.model_name
    ActiveModel::Name.new(self, nil, "UtaacDecision")
  end

  attributes.each do |attribute_name|
    define_method(attribute_name) do
      delegate_if_document_exists(attribute_name)
    end
  end

private

  def finder_schema
    SpecialistPublisherWiring.get(:utaac_decision_finder_schema)
  end
end
