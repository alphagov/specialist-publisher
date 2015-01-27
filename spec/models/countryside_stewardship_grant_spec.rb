require "fast_spec_helper"
require "countryside_stewardship_grant"

RSpec.describe CountrysideStewardshipGrant do

  it "is a DocumentMetadataDecorator" do
    doc = double(:document)
    expect(CountrysideStewardshipGrant.new(doc)).to be_a(DocumentMetadataDecorator)
  end

end
