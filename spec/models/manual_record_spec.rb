require "spec_helper"

describe ManualRecord, hits_db: true do
  subject(:record) { ManualRecord.new }

  describe "#latest_edition" do
    context "when there are several previous editions" do
      let!(:editions) {
        [
          record.editions.create!(state: "published", version_number: 2),
          record.editions.create!(state: "draft", version_number: 3),
          record.editions.create!(state: "published", version_number: 1),
        ]
      }

      it "returns the edition with the highest version number" do
        expect(record.latest_edition.version_number).to eq(3)
      end
    end
  end

  describe "#new_or_existing_draft_edition" do
    context "when a draft edition exists" do
      let!(:edition) { record.editions.create!(state: "draft") }

      it "returns the existing draft edition" do
        expect(record.new_or_existing_draft_edition).to eq(edition)
      end
    end

    context "when both published and draft editions exist" do
      before do
        @draft_edition = record.editions.create!(state: "draft", version_number: 2)
        record.editions.create!(state: "published", version_number: 1)
      end

      it "returns the existing draft edition" do
        expect(record.new_or_existing_draft_edition).to eq(@draft_edition)
      end
    end

    context "when no editions exist" do
      it "builds a new draft edition" do
        new_edition = record.new_or_existing_draft_edition
        expect(new_edition).not_to be_persisted
        expect(new_edition.state).to eq("draft")
        expect(new_edition.version_number).to eq(1)
      end
    end

    context "when only non-draft editions exists" do
      before do
        record.editions.create!(state: "published", version_number: 1)
      end

      it "builds a new draft edition" do
        new_edition = record.new_or_existing_draft_edition
        expect(new_edition).not_to be_persisted
        expect(new_edition.state).to eq("draft")
        expect(new_edition.version_number).to eq(2)
      end
    end
  end

  describe "#find_by_organisation" do
    let!(:cma_manual) {
      ManualRecord.create!(organisation_slug: "cma")
    }

    let!(:tea_manual) {
      ManualRecord.create!(organisation_slug: "ministry-of-tea")
    }

    it "filters by organisation" do
      expect(ManualRecord.find_by_organisation("cma").to_a).to eq([cma_manual])
    end
  end

  describe "#all_by_updated_at" do
    let!(:middle_edition) {
      ManualRecord.create!(updated_at: 2.days.ago)
    }

    let!(:early_edition) {
      ManualRecord.create!(updated_at: 3.days.ago)
    }

    let!(:later_edition) {
      ManualRecord.create!(updated_at: 1.day.ago)
    }

    it "returns manuals ordered with most recently updated first" do
      expect(ManualRecord.all_by_updated_at.to_a).to eq([later_edition, middle_edition, early_edition])
    end
  end

  describe "#tags" do

    it "can store tags" do
      tags = [
        {
          type: "A tag type",
          slug: "a-tag-slug",
        }
      ]

      record.editions.create!(tags: tags)

      expect(record.latest_edition.tags).to eq(tags)
    end
  end
end
