require "fast_spec_helper"
require "asylum_support_decision"

RSpec.describe AsylumSupportDecision do

  it "is a DocumentMetadataDecorator" do
    doc = double(:document)
    expect(AsylumSupportDecision.new(doc)).to be_a(DocumentMetadataDecorator)
  end

end
