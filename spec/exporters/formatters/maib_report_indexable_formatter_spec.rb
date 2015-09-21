require "spec_helper"
require "formatters/maib_report_indexable_formatter"

RSpec.describe MaibReportIndexableFormatter do
  let(:document) {
    double(
      :maib_report,
      body: double,
      slug: double,
      summary: double,
      title: double,
      updated_at: double,
      minor_update?: false,
      date_of_occurrence: double,
      report_type: double,
      vessel_type: double
    )
  }

  subject(:formatter) { MaibReportIndexableFormatter.new(document) }

  it_should_behave_like "a specialist document indexable formatter"

  it "should have a type of maib_report" do
    expect(formatter.type).to eq("maib_report")
  end
end
