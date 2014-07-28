require "fast_spec_helper"
require "cma_case"

RSpec.describe CmaCase do

  it "is a DocumentMetadataDecorator" do
    doc = double(:document)
    expect(CmaCase.new(doc)).to be_a(DocumentMetadataDecorator)
  end

end
