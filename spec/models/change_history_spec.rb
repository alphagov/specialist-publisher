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
      expect(change_history).to eq(subject)
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

  describe "#first_published!" do
    it "adds a 'First published.' item to the change history" do
      change_history = described_class.new
      change_history.first_published!

      expect(change_history.as_json).to eq([
        {
          "public_timestamp" => Time.zone.now.iso8601,
          "note" => "First published."
        }
      ])
    end

    context "when the change history is not empty" do
      it "raises a helpful error" do
        expect {
          subject.first_published!
        }.to raise_error(/must be empty/)
      end
    end
  end

  describe "#add_item" do
    it "adds an item to the change history with the current time" do
      expect {
        subject.add_item("New change note")
      }.to change { subject.size }.by(1)

      last_item = subject.as_json.last

      expect(last_item.fetch("note")).to eq("New change note")
      expect(last_item.fetch("public_timestamp")).to eq(Time.zone.now.iso8601)
    end

    it "does not leak access to the change history item" do
      change_history = described_class.new
      expect(change_history.first_published!).to be_nil
    end
  end

  describe "#update_item" do
    it "updates the last item in the change history" do
      expect {
        subject.update_item("Updated change note")
      }.not_to change { subject.size }

      last_item = subject.as_json.last
      expect(last_item.fetch("note")).to eq("Updated change note")
      expect(last_item.fetch("public_timestamp")).to eq(Time.zone.now.iso8601)
    end

    it "raises an error if there's nothing to update" do
      expect {
        described_class.new.update_item("change note")
      }.to raise_error(EmptyChangeHistoryError)
    end
  end

  describe "#latest_change_note" do
    it "returns the latest item's change note" do
      expect(subject.latest_change_note).to eq("Some change note")
    end

    it "returns nil if the change history is empty" do
      expect(described_class.new.latest_change_note).to be_nil
    end
  end
end
