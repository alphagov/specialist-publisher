require "spec_helper"
require "formatters/international_development_fund_indexable_formatter"

RSpec.describe InternationalDevelopmentFundIndexableFormatter do
  let(:document) {
    double(
      :international_development_fund,
      body: double,
      slug: double,
      summary: double,
      title: double,
      updated_at: double,
      minor_update?: false,
      fund_state: double,
      location: double,
      development_sector: double,
      eligible_entities: double,
      value_of_funding: double
    )
  }

  subject(:formatter) { InternationalDevelopmentFundIndexableFormatter.new(document) }

  it_should_behave_like "a specialist document indexable formatter"

  it "should have a type of international_development_fund" do
    expect(formatter.type).to eq("international_development_fund")
  end
end
