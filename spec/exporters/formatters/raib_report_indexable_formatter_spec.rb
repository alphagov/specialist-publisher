require "spec_helper"
require "spec/exporters/formatters/abstract_indexable_formatter_spec"
require "spec/exporters/formatters/abstract_specialist_document_indexable_formatter_spec"
require "formatters/raib_report_indexable_formatter"

RSpec.describe RaibReportIndexableFormatter do
  let(:document) {
    double(
      :raib_report,
      body: double,
      slug: double,
      summary: double,
      title: double,
      updated_at: double,
      minor_update?: false,
      date_of_occurrence: double,
      report_type: double,
      railway_type: double
    )
  }

  subject(:formatter) { RaibReportIndexableFormatter.new(document) }

  it_should_behave_like "a specialist document indexable formatter"

  it "should have a type of raib_report" do
    expect(formatter.type).to eq("raib_report")
  end
end
