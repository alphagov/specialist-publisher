require "fast_spec_helper"
require "aaib_report"

RSpec.describe AaibReport do
  subject(:report) { AaibReport.new(document) }
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

  let(:report_attributes) {
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
      date_of_occurrence: date_of_occurrence,
      aircraft_category: aircraft_category,
      report_type: report_type,
    }
  }

  let(:date_of_occurrence) { double(:date_of_occurrence) }
  let(:aircraft_category) { double(:aircraft_category) }
  let(:report_type) { double(:report_type) }

  it "is a true decorator" do
    expect(document).to receive(:arbitrary_message)
    report.arbitrary_message
  end

  describe "#update" do
    it "updates the document, separating out extra attributes" do
      report.update(report_attributes)

      expect(document).to have_received(:update).with(document_attributes)
    end
  end

  describe "#attributes" do
    it "returns attributes from document, including extra_fields" do
      expect(report.attributes).to eq(report_attributes)
    end
  end
end
