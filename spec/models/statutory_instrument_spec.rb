require "spec_helper"
require "models/valid_against_schema"

RSpec.describe StatutoryInstrument do
  let(:payload) { FactoryBot.create(:statutory_instrument) }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"

  it "is not exportable" do
    expect(described_class).not_to be_exportable
  end

  describe ".title_for_new_document" do
    it "retains the capitalisation of the act name" do
      expect(StatutoryInstrument.title_for_new_document).to eq("EU Withdrawal Act 2018 statutory instrument")
    end
  end

  describe "sift_end_date" do
    subject(:instance) do
      StatutoryInstrument.new(body: "", sift_end_date: "2016-01-01", sifting_status: "withdrawn")
    end

    it "is invalid on a withdrawn document" do
      instance.validate
      expect(instance.errors[:sift_end_date].first).to eq("must be blank when withdrawn")
    end

    it "is valid on a document in an open or closed state" do
      %w[open closed].each do |state|
        instance.sifting_status = state
        instance.validate
        expect(instance.errors[:sift_end_date]).to be_empty
      end
    end
  end

  describe "withdrawn_date" do
    subject(:instance) do
      StatutoryInstrument.new(body: "", withdrawn_date: "2016-01-01")
    end

    it "is invalid on a non-withdrawn document" do
      instance.sifting_status = "open"
      instance.validate
      expect(instance.errors[:withdrawn_date].first).to eq("must be blank if not withdrawn")
    end

    it "is valid on a withdrawn document" do
      instance.sifting_status = "withdrawn"
      instance.validate
      expect(instance.errors[:withdrawn_date]).to be_empty
    end
  end
end
