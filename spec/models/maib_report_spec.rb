require "fast_spec_helper"
require "maib_report"

RSpec.describe MaibReport do

  it "is a DocumentMetadataDecorator" do
    doc = double(:document)
    expect(MaibReport.new(doc)).to be_a(DocumentMetadataDecorator)
  end

end
