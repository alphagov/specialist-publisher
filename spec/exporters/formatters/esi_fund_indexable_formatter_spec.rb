require "spec_helper"
require "formatters/esi_fund_indexable_formatter"

RSpec.describe EsiFundIndexableFormatter do
  let(:document) {
    double(
    :esi_fund,
    body: double,
    slug: double,
    summary: double,
    title: double,
    fund_state: double,
    fund_type: double,
    location: double,
    funding_source: double,
    closing_date: double,
    updated_at: double,
    minor_update?: false,
    )
  }

  subject(:formatter) { EsiFundIndexableFormatter.new(document) }

  it_should_behave_like "a specialist document indexable formatter"

  it "should have a type of european_structural_investment_fund" do
    expect(formatter.type).to eq("european_structural_investment_fund")
  end
end
