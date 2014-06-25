require "fast_spec_helper"
require "aaib_report"

RSpec.describe AaibReport do

  it "is a DocumentMetadataDecorator" do
    doc = double(:document)
    AaibReport.new(doc).should be_a(DocumentMetadataDecorator)
  end

end
