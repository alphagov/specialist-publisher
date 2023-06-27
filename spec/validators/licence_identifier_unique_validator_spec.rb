require "spec_helper"

class LicenceTransaction
  include ActiveModel::API
  attr_accessor :licence_transaction_licence_identifier
end

RSpec.describe LicenceIdentifierUniqueValidator do
  let(:existing_identifier) { "1234-5-6" }
  let(:existing_record) do
    LicenceTransaction.new(licence_transaction_licence_identifier: existing_identifier)
  end

  before do
    allow(LicenceTransaction).to receive(:find_each) do |&block|
      block.call(existing_record)
    end
  end

  subject { described_class.new(attributes: [:licence_transaction_licence_identifier]) }

  context "when the records identifier is unique" do
    let(:record) do
      LicenceTransaction.new(licence_transaction_licence_identifier: "7777-7-1")
    end

    it "validates successfully" do
      subject.validate_each(
        record,
        :licence_transaction_licence_identifier,
        record.licence_transaction_licence_identifier,
      )

      expect(record.errors).to be_blank
    end
  end

  context "when the same, existing record is validated" do
    it "validates successfully" do
      subject.validate_each(
        existing_record,
        :licence_transaction_licence_identifier,
        existing_record.licence_transaction_licence_identifier,
      )

      expect(existing_record.errors).to be_blank
    end
  end

  context "when the records identifier is not unique" do
    let(:record) do
      LicenceTransaction.new(licence_transaction_licence_identifier: existing_identifier)
    end

    it "validates unsuccessfully" do
      subject.validate_each(
        record,
        :licence_transaction_licence_identifier,
        record.licence_transaction_licence_identifier,
      )

      expect(record.errors[:licence_transaction_licence_identifier]).to eq(
        [record.errors.generate_message(:licence_transaction_licence_identifier, :taken)],
      )
    end
  end
end
