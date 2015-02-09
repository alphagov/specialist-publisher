require "fast_spec_helper"
require "esi_fund"

RSpec.describe EsiFund do

  it "is a DocumentMetadataDecorator" do
    doc = double(:document)
    expect(EsiFund.new(doc)).to be_a(DocumentMetadataDecorator)
  end

end
