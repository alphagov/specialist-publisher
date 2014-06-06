require "fast_spec_helper"
require "cma_case"

RSpec.describe CmaCase do
  subject(:cma_case) { CmaCase.new(document) }
  let(:document) {
    double(
      :document,
      attributes: document_attributes,
      update: nil,
    )
  }

  let(:document_attributes) {
    basic_attributes.merge(
      extra_fields: extra_attributes
    )
  }

  let(:cma_attributes) {
    basic_attributes.merge(extra_attributes)
  }

  let(:basic_attributes) {
    {
      foo: "bar",
      baz: "qux",
    }
  }

  let(:extra_attributes) {
    {
      opened_date: opened_date,
      closed_date: closed_date,
      case_type: case_type,
      case_state: case_state,
      market_sector: market_sector,
      outcome_type: outcome_type,
    }
  }

  let(:opened_date) { double(:opened_date) }
  let(:closed_date) { double(:closed_date) }
  let(:case_type) { double(:case_type) }
  let(:case_state) { double(:case_state) }
  let(:market_sector) { double(:market_sector) }
  let(:outcome_type) { double(:outcome_type) }

  it "is a true decorator" do
    expect(document).to receive(:arbitrary_message)
    cma_case.arbitrary_message
  end

  describe "#update" do
    it "updates the document, separating out extra attributes" do
      cma_case.update(cma_attributes)

      expect(document).to have_received(:update).with(document_attributes)
    end
  end

  describe "#attributes" do
    it "returns attributes from document, including extra_fields" do
      expect(cma_case.attributes).to eq(cma_attributes)
    end
  end
end
