require "spec_helper"
require "models/valid_against_schema"

RSpec.describe ProductSafetyAlert do
  let(:payload) { FactoryBot.create(:product_safety_alert) }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"

  it "is not exportable" do
    expect(described_class).not_to be_exportable
  end

  it "is valid for the default factory" do
    expect(described_class.from_publishing_api(payload)).to be_valid
  end
end
