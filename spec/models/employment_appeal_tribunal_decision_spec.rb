require "fast_spec_helper"
require "employment_appeal_tribunal_decision"

RSpec.describe EmploymentAppealTribunalDecision do

  it "is a DocumentMetadataDecorator" do
    doc = double(:document)
    expect(EmploymentAppealTribunalDecision.new(doc)).to be_a(DocumentMetadataDecorator)
  end

end
