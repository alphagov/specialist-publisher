require "spec_helper"

RSpec.describe TimeValidator do
  describe "#validate_each" do
    let(:record) { double(:record) }
    let(:errors) { ActiveModel::Errors.new(record) }
    before { allow(record).to receive(:errors).and_return(errors) }

    subject { described_class.new(attributes: [:time]) }

    it "assumes presence: true validation will be used to detect nils if we don't allow them for this attribute so doesn't add an error if the date value is blank" do
      subject.validate_each(record, :time, nil)
      expect(record.errors[:time]).to be_empty
    end

    it "adds an error to the record if the date value is unparseable" do
      subject.validate_each(record, :time, "25:01")
      expect(record.errors[:time]).to eq(["is not a valid time"])
    end

    it "adds an error to the record if the date value contains large integer values" do
      subject.validate_each(record, :time, "432423234243223432:432423542423542")
      expect(record.errors[:time]).to eq(["is not a valid time"])
    end

    it "doesn't add an error if the date value can be parsed" do
      subject.validate_each(record, :time, "10:47")
      expect(record.errors).to be_empty
    end
  end
end
