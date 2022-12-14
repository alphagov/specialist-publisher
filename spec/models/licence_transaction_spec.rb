require "spec_helper"
require "models/valid_against_schema"

RSpec.describe LicenceTransaction do
  let(:payload) { FactoryBot.create(:licence_transaction) }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"

  it "is not exportable" do
    expect(subject.class).not_to be_exportable
  end

  it "should have a rendering app of frontend" do
    expect(subject.rendering_app).to eq "frontend"
  end
end
