require "formatters/abstract_indexable_formatter"

RSpec.shared_examples_for "an indexable formatter" do
  before do
    allow(document).to receive(:previous_major_updated_at).and_return(double)
  end

  it "should respond to #id" do
    expect(formatter).to respond_to(:id)
  end

  it "should respond to #indexable_attributes with a Hash" do
    expect(formatter.indexable_attributes).to be_a(Hash)
  end

  it "should respond to #type" do
    expect(formatter).to respond_to(:type)
  end
end
