require "spec_helper"

describe ManualRecord, hits_db: true do
  subject(:record) { ManualRecord.new }

  describe "#new_or_existing_draft_edition" do
    context "when a draft edition exists" do
      before do
        @edition = record.editions.create!(state: 'draft')
      end

      it "returns the existing draft edition" do
        expect(record.new_or_existing_draft_edition).to eq(@edition)
      end
    end

    context "when no editions exist" do
      it "builds a new draft edition" do
        new_edition = record.new_or_existing_draft_edition
        expect(new_edition).not_to be_persisted
        expect(new_edition.state).to eq('draft')
        expect(new_edition.version_number).to eq(1)
      end
    end

    context "when only non-draft editions exists" do
      before do
        record.editions.create!(state: 'published', version_number: 1)
      end

      it "builds a new draft edition" do
        new_edition = record.new_or_existing_draft_edition
        expect(new_edition).not_to be_persisted
        expect(new_edition.state).to eq('draft')
        expect(new_edition.version_number).to eq(2)
      end
    end
  end
end
