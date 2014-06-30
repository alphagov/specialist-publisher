require "fast_spec_helper"
require "cma_case"

RSpec.describe CmaCase do

  it "is a DocumentMetadataDecorator" do
    doc = double(:document)
    CmaCase.new(doc).should be_a(DocumentMetadataDecorator)
  end

end
