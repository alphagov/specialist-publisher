require "spec_helper"
require "formatters/aaib_report_indexable_formatter"

RSpec.describe AaibReportIndexableFormatter do
  let(:document) {
    double(
      :aaib_report,
      body: double,
      slug: double,
      summary: double,
      title: double,
      updated_at: double,
      minor_update?: false,
      aircraft_category: double,
      report_type: double,
      date_of_occurrence: double,
      location: double,
      aircraft_type: double,
      registration: double
    )
  }

  subject(:formatter) { AaibReportIndexableFormatter.new(document) }

  it_should_behave_like "a specialist document indexable formatter"

  it "should have a type of aaib_report" do
    expect(formatter.type).to eq("aaib_report")
  end
end
