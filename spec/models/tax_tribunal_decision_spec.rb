require "fast_spec_helper"
require "tax_tribunal_decision"

RSpec.describe TaxTribunalDecision do

  it "is a DocumentMetadataDecorator" do
    doc = double(:document)
    expect(TaxTribunalDecision.new(doc)).to be_a(DocumentMetadataDecorator)
  end

end
