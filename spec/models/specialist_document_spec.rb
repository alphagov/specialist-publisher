require 'spec_helper'

describe SpecialistDocument do

  it "loads attributes provided via #new" do
    document = SpecialistDocument.new(title: "A title", summary: "A summary")
    document.title.should == "A title"
    document.summary.should == "A summary"
  end

  it "is invalid if it has any errors" do
    document = SpecialistDocument.new

    document.should be_valid
    document.errors = {title: ["is required"]}
    document.should_not be_valid
  end

end
