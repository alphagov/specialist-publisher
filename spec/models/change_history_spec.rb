require "spec_helper"

RSpec.describe ChangeHistory do
  subject do
    described_class.new([
      described_class::Item.new(
        public_timestamp: DateTime.new(2016, 1, 1),
        change_note: "First published.",
      ),
      described_class::Item.new(
        public_timestamp: DateTime.new(2016, 2, 2),
        change_note: "Some change note",
      ),
    ])
  end

  let(:data_structure) do
    [
      {
        "public_timestamp" => "2016-01-01T00:00:00+00:00",
        "note" => "First published."
      },
      {
        "public_timestamp" => "2016-02-02T00:00:00+00:00",
        "note" => "Some change note"
      },
    ]
  end

  around do |example|
    Timecop.freeze { example.run }
  end

  it "encapsulates its items in an attempt to keep all change history logic in this model" do
    expect(subject).not_to respond_to(:items)
  end

  describe ".parse" do
    it "parses the change history from the data structure stored in the details hash" do
      change_history = described_class.parse(data_structure)
      expect(change_history.as_json).to eq(subject.as_json)
    end
  end

  describe "#as_json" do
    it "builds the data structure to be stored in the details hash from the change history" do
      result = subject.as_json
      expect(result).to eq(data_structure)
    end
  end

  describe "#size" do
    it "returns the size of the change history" do
      expect(subject.size).to eq(2)
      expect(described_class.new.size).to eq(0)
    end
  end
end
