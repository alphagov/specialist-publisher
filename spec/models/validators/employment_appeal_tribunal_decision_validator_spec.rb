require "spec_helper"

require "validators/employment_appeal_tribunal_decision_validator"

RSpec.describe EmploymentAppealTribunalDecisionValidator do

  let(:entity) {
    double(
      :entity,
      title: double,
      summary: double,
      body: "body",
      tribunal_decision_categories: [double],
      tribunal_decision_decision_date: "2015-11-01",
      tribunal_decision_landmark:  double,
      tribunal_decision_sub_categories: [double],
    )
  }
  let(:document_type) { "employment_appeal_tribunal_decision" }

  subject(:validatable) { EmploymentAppealTribunalDecisionValidator.new(entity) }

end
