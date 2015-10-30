require "spec_helper"

require "validators/asylum_support_decision_validator"
require_relative "tribunal_decision_sub_category_relates_to_parent_validator_spec"

RSpec.describe AsylumSupportDecisionValidator do

  let(:entity) {
    double(
      :entity,
      title: double,
      summary: double,
      body: "body",
      tribunal_decision_category: category,
      tribunal_decision_decision_date: "2015-11-01",
      tribunal_decision_judges: [double],
      tribunal_decision_landmark: double,
      tribunal_decision_reference_number: double,
      tribunal_decision_sub_category: sub_category,
    )
  }
  let(:document_type) { "asylum_support_decision" }

  subject(:validatable) { AsylumSupportDecisionValidator.new(entity) }

  it_behaves_like "tribunal decision sub_category validator"

  describe "#errors" do
    before do
      validatable.valid?
    end

    context "when sub_category matches alternate prefix for parent category" do
      let(:category) { "section-95-support-for-asylum-seekers" }
      let(:sub_category) { ["section-95-jurisdiction"] }

      it "returns an empty error hash" do
        errors = validatable.errors.messages
        expect(errors).to eq({})
      end
    end
  end
end
