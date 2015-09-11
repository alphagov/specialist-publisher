require "fast_spec_helper"
require "utaac_decision"

RSpec.describe UtaacDecision do

  it "is a DocumentMetadataDecorator" do
    doc = double(:document)
    expect(UtaacDecision.new(doc)).to be_a(DocumentMetadataDecorator)
  end

end
