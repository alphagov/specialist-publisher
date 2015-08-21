require "spec_helper"
require "spec/exporters/formatters/abstract_indexable_formatter_spec"
require "spec/exporters/formatters/abstract_specialist_document_indexable_formatter_spec"
require "formatters/aaib_report_indexable_formatter"

RSpec.describe AsylumSupportDecisionIndexableFormatter do
  let(:document) {
    double(
      :asylum_support_decision,
      body: double,
      slug: double,
      summary: double,
      title: double,
      updated_at: double,
      minor_update?: false,

      tribunal_decision_decision_date: double,
      tribunal_decision_judges: double,
      tribunal_decision_category: double,
      tribunal_decision_sub_category: double,
      tribunal_decision_landmark: double,
      tribunal_decision_reference_number: double,
    )
  }

  subject(:formatter) { AsylumSupportDecisionIndexableFormatter.new(document) }

  it_should_behave_like "a specialist document indexable formatter"

  it "should have a type of asylum_support_decision" do
    expect(formatter.type).to eq("asylum_support_decision")
  end
end
