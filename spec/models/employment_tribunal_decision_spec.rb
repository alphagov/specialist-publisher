require "fast_spec_helper"
require "employment_tribunal_decision"

RSpec.describe EmploymentTribunalDecision do

  it "is a DocumentMetadataDecorator" do
    doc = double(:document)
    expect(EmploymentTribunalDecision.new(doc)).to be_a(DocumentMetadataDecorator)
  end

end
