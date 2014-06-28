require "spec_helper"
require "spec/lib/abstract_indexable_formatter_spec"
require "cma_case_indexable_formatter"

RSpec.describe CmaCaseIndexableFormatter do
  let(:cma_case) {
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
    )
  }

  subject(:formatter) { CmaCaseIndexableFormatter.new(cma_case) }

  it_should_behave_like "an indexable formatter"

  it "should have a type of cma_case" do
    expect(formatter.type).to eq("cma_case")
  end
end
