require "spec_helper"

require "validators/utaac_decision_validator"
require_relative "tribunal_decision_sub_category_relates_to_parent_validator_spec"

RSpec.describe UtaacDecisionValidator do

  let(:entity) {
    double(
      :entity,
      title: double,
      summary: double,
      body: "body",
      tribunal_decision_category: category,
      tribunal_decision_decision_date: "2015-11-01",
      tribunal_decision_judges: [double],
      tribunal_decision_sub_category: sub_category,
    )
  }
  let(:document_type) { "utaac_decision" }

  subject(:validatable) { UtaacDecisionValidator.new(entity) }

  it_behaves_like "tribunal decision sub_category validator"

end
