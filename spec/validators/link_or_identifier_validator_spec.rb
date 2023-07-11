require "spec_helper"

class LicenceTransaction
  include ActiveModel::API
  attr_accessor :licence_transaction_continuation_link,
                :licence_transaction_will_continue_on,
                :licence_transaction_licence_identifier,
                :imported
end

RSpec.describe LinkOrIdentifierValidator do
  let(:imported) { false }
  let(:record) do
    LicenceTransaction.new(
      {
        licence_transaction_continuation_link: link,
        licence_transaction_will_continue_on: will_continue_on,
        licence_transaction_licence_identifier: identifier,
        imported:,
      },
    )
  end

  subject { described_class.new }

  context "when a link and will continue on text exists" do
    let(:link) { "https://www.gov.uk" }
    let(:will_continue_on) { "GDS" }
    let(:identifier) { nil }

    it "validates successfully" do
      subject.validate(record)
      expect(record.errors).to be_blank
    end
  end

  context "when an identifier exists" do
    let(:link) { nil }
    let(:will_continue_on) { nil }
    let(:identifier) { "9090-1-2" }

    it "validates successfully" do
      subject.validate(record)
      expect(record.errors).to be_blank
    end
  end

  context "when a link exists without will continue on text for an imported licence" do
    let(:link) { "https://www.gov.uk" }
    let(:will_continue_on) { nil }
    let(:identifier) { nil }
    let(:imported) { true }

    it "validates successfully" do
      subject.validate(record)
      expect(record.errors[:licence_transaction_continuation_link]).to be_blank
    end
  end

  context "when a link, will continue on and link doesn't exist" do
    let(:link) { nil }
    let(:will_continue_on) { nil }
    let(:identifier) { nil }

    it "validates unsuccessfully" do
      subject.validate(record)
      expect(record.errors[:base]).to eq(
        [record.errors.generate_message(:base, :link_and_identifier_exists)],
      )
    end
  end

  context "when a link exists without will continue on text" do
    let(:link) { "https://www.gov.uk" }
    let(:will_continue_on) { nil }
    let(:identifier) { nil }

    it "validates unsuccessfully" do
      subject.validate(record)
      expect(record.errors[:licence_transaction_will_continue_on]).to eq(
        [record.errors.generate_message(:licence_transaction_will_continue_on, :blank)],
      )
    end
  end

  context "when will continue on text exists without a link" do
    let(:link) { nil }
    let(:will_continue_on) { "GDS" }
    let(:identifier) { nil }

    it "validates unsuccessfully" do
      subject.validate(record)
      expect(record.errors[:licence_transaction_continuation_link]).to eq(
        [record.errors.generate_message(:licence_transaction_continuation_link, :blank)],
      )
    end
  end
end
