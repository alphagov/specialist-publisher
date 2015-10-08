require "spec_helper"

require "validators/tax_tribunal_decision_validator"

RSpec.describe TaxTribunalDecisionValidator do

  let(:entity) {
    double(
      :entity,
      title: double,
      summary: double,
      body: "body",
      tribunal_decision_category: category,
      tribunal_decision_decision_date: "2015-11-01",
    )
  }
  let(:document_type) { "tax_tribunal_decision" }

  subject(:validatable) { TaxTribunalDecisionValidator.new(entity) }

end
