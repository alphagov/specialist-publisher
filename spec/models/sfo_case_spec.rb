require "spec_helper"
require "models/valid_against_schema"

RSpec.describe SfoCase do
  let(:payload) { FactoryBot.create(:sfo_case) }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"
  subject(:sfo_case) { described_class.from_publishing_api(payload) }

  it "is not exportable" do
    expect(described_class).not_to be_exportable
  end

  describe "validations" do
    it "is valid from the payload" do
      expect(sfo_case).to be_valid
    end

    it "is valid if the opened date is a valid date" do
      sfo_case.sfo_case_opened_date = "2023-01-01"
      expect(sfo_case).to be_valid
    end

    it "is invalid if the case state is missing" do
      sfo_case.sfo_case_state = nil
      expect(sfo_case).not_to be_valid
    end

    it "is invalid if the opened date is missing" do
      sfo_case.sfo_case_opened_date = nil
      expect(sfo_case).not_to be_valid
    end

    it "is invalid if the opened date is not a valid date" do
      sfo_case.sfo_case_opened_date = "invalid_date"
      expect(sfo_case).not_to be_valid
    end
  end
end
