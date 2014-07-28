require "fast_spec_helper"
require "aaib_report"

RSpec.describe InternationalDevelopmentFund do

  it "is a DocumentMetadataDecorator" do
    doc = double(:document)
    expect(
      InternationalDevelopmentFund.new(doc)
    ).to be_a(DocumentMetadataDecorator)
  end

end
