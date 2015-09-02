require "spec_helper"
require "spec/exporters/formatters/abstract_indexable_formatter_spec"
require "spec/exporters/formatters/abstract_specialist_document_indexable_formatter_spec"
require "formatters/aaib_report_indexable_formatter"

RSpec.describe AsylumSupportDecisionIndexableFormatter do
  let(:document) {
    double(
      :asylum_support_decision,
      body: double("body"),
      slug: "/slug",
      summary: double,
      title: double,
      updated_at: double,
      minor_update?: false,
      public_updated_at: double,

      tribunal_decision_judges: [double],
      tribunal_decision_category: double,
      tribunal_decision_sub_category: double,
      tribunal_decision_landmark: double,
      tribunal_decision_reference_number: double,
      tribunal_decision_decision_date: double,
      hidden_indexable_content: double,
    )
  }

  subject(:formatter) { AsylumSupportDecisionIndexableFormatter.new(document) }

  include_context "schema available"

  it_should_behave_like "a specialist document indexable formatter"

  it "should have a type of asylum_support_decision" do
    expect(formatter.type).to eq("asylum_support_decision")
  end

  context "without hidden_indexable_content" do
    it "should have body as its indexable_content" do
      allow(document).to receive(:hidden_indexable_content).and_return(nil)
      expect(formatter.indexable_attributes[:indexable_content]).to eq(document.body)
    end
  end

  context "with hidden_indexable_content" do
    it "should have hidden_indexable_content as its indexable_content" do
      expect(formatter.indexable_attributes[:indexable_content]).to eq(document.hidden_indexable_content)
    end
  end

end
