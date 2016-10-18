require "spec_helper"

RSpec.describe DateValidator do
  describe "#validate_each" do
    let(:record) { double(:record) }
    let(:errors) { ActiveModel::Errors.new(record) }
    before { allow(record).to receive(:errors).and_return(errors) }

    subject { described_class.new(attributes: [:dob]) }

    it "adds an error to the record if the date value is unparseable" do
      subject.validate_each(record, :dob, "31-02-2013")
      expect(record.errors[:dob]).to eq(["is not a valid date"])
    end

    it "adds an error to the record if the date value contains large integer values" do
      subject.validate_each(record, :dob, "31236445328465236254-023646452342-2013342942867428964")
      expect(record.errors[:dob]).to eq(["is not a valid date"])
    end

    it "doesn't add an error if the date value can be parsed" do
      subject.validate_each(record, :dob, "25-02-2013")
      expect(record.errors).to be_empty
    end
  end
end
