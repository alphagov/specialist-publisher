require "spec_helper"
require "spec/exporters/formatters/abstract_indexable_formatter_spec"
require "spec/exporters/formatters/abstract_specialist_document_indexable_formatter_spec"
require "formatters/esi_fund_indexable_formatter"

RSpec.describe EsiFundIndexableFormatter do
  let(:document) {
    double(
    :esi_fund,
    body: double,
    slug: double,
    summary: double,
    title: double,
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
