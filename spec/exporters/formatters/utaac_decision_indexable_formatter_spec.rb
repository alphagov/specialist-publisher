require "spec_helper"
require "formatters/aaib_report_indexable_formatter"
require_relative "tribunal_decision_indexable_formatter_spec"

RSpec.describe UtaacDecisionIndexableFormatter do
  let(:sub_category) { [double] }
  let(:document) {
    double(
      :utaac_decision,
      body: double,
      slug: "/slug",
      summary: double,
      title: double,
      updated_at: double,
      minor_update?: false,
      public_updated_at: double,

      hidden_indexable_content: double,
      tribunal_decision_category: double,
      tribunal_decision_decision_date: double,
      tribunal_decision_judges: [double],
      tribunal_decision_sub_category: sub_category,
    )
  }

  subject(:formatter) { UtaacDecisionIndexableFormatter.new(document) }

  let(:document_type) { formatter.type }
  let(:humanized_facet_value) { double }
  include_context "schema with humanized_facet_value available"

  it_behaves_like "a specialist document indexable formatter"
  it_behaves_like "a tribunal decision indexable formatter"

  it "should have a type of utaac_decision" do
    expect(formatter.type).to eq("utaac_decision")
  end

  context "without hidden_indexable_content" do
    it "should have body as its indexable_content" do
      allow(document).to receive(:body).and_return("body text")

      allow(document).to receive(:hidden_indexable_content).and_return(nil)
      expect(formatter.indexable_attributes[:indexable_content]).to eq("body text")
    end
  end

  context "with hidden_indexable_content" do
    it "should have hidden_indexable_content as its indexable_content" do
      allow(document).to receive(:body).and_return("body text")
      allow(document).to receive(:hidden_indexable_content).and_return("hidden indexable content text")

      indexable = formatter.indexable_attributes[:indexable_content]
      expect(indexable).to eq("hidden indexable content text\nbody text")
    end
  end

end
