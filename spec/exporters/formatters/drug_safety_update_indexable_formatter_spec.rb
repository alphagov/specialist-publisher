require "spec_helper"
require "formatters/drug_safety_update_indexable_formatter"

RSpec.describe DrugSafetyUpdateIndexableFormatter do
  let(:document) {
    double(
      :drug_safety_update,
      body: double,
      slug: double,
      summary: double,
      title: double,
      updated_at: double,
      minor_update?: false,
      therapeutic_area: double,
      first_published_at: double
    )
  }

  subject(:formatter) { DrugSafetyUpdateIndexableFormatter.new(document) }

  it_should_behave_like "a specialist document indexable formatter"

  it "should have a type of drug_safety_update" do
    expect(formatter.type).to eq("drug_safety_update")
  end
end
