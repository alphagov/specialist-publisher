require "fast_spec_helper"
require "aaib_report"

RSpec.describe InternationalDevelopmentFund do

  it "is a DocumentMetadataDecorator" do
    doc = double(:document)
    InternationalDevelopmentFund.new(doc).should be_a(DocumentMetadataDecorator)
  end

end
