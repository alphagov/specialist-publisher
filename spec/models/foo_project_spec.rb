require "spec_helper"
require "models/valid_against_schema"

RSpec.describe FooProject do
  let(:payload) { FactoryBot.create(:foo_project) }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"

  it "is not exportable" do
    expect(described_class).not_to be_exportable
  end

  describe "validations" do
    subject { described_class.from_publishing_api(payload) }

    it "is valid for the default factory" do
      expect(subject).to be_valid
    end

    it "is invalid if the opened date is after the closed date" do
      subject.foo_project_opened_date = "2016-01-01"
      subject.foo_project_closed_date = "2015-12-31"

      expect(subject).to be_invalid
      expect(subject.errors[:foo_project_opened_date]).to eq ["must be before closed date"]
    end

    it "is valid if opened/closed date are nil" do
      subject.foo_project_opened_date = nil
      subject.foo_project_closed_date = nil
      expect(subject).to be_valid

      subject.foo_project_opened_date = "2016-01-01"
      expect(subject).to be_valid

      subject.foo_project_opened_date = nil
      subject.foo_project_closed_date = "2015-12-31"
      expect(subject).to be_valid
    end
  end
end
