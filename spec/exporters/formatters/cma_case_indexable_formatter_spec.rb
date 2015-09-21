require "spec_helper"
require "formatters/cma_case_indexable_formatter"

RSpec.describe CmaCaseIndexableFormatter do
  let(:document) {
    double(
      :cma_case,
      body: double,
      case_state: double,
      case_type: double,
      market_sector: double,
      outcome_type: double,
      slug: double,
      summary: double,
      title: double,
      opened_date: double,
      closed_date: double,
      updated_at: double,
      minor_update?: false,
    )
  }

  subject(:formatter) { CmaCaseIndexableFormatter.new(document) }

  it_should_behave_like "a specialist document indexable formatter"

  it "should have a type of cma_case" do
    expect(formatter.type).to eq("cma_case")
  end
end
