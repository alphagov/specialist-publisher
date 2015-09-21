require "spec_helper"
require "formatters/countryside_stewardship_grant_indexable_formatter"

RSpec.describe CountrysideStewardshipGrantIndexableFormatter do
  let(:document) {
    double(
    :countryside_stewardship_grant,
    body: double,
    slug: double,
    summary: double,
    title: double,
    grant_type: double,
    land_use: double,
    tiers_or_standalone_items: double,
    funding_amount: double,
    updated_at: double,
    minor_update?: false,
    )
  }

  subject(:formatter) { CountrysideStewardshipGrantIndexableFormatter.new(document) }

  it_should_behave_like "a specialist document indexable formatter"

  it "should have a type of countryside_stewardship_grant" do
    expect(formatter.type).to eq("countryside_stewardship_grant")
  end
end
