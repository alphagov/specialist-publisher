require "spec_helper"
require "models/valid_against_schema"

RSpec.describe SpecialistDocument::AaibReport do
  let(:payload) { FactoryBot.create(:aaib_report) }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"

  it "is not exportable" do
    expect(subject.class).not_to be_exportable
  end
end
