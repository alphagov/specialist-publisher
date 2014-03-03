require 'spec_helper'

describe SpecialistDocument do
  subject(:doc) {
    SpecialistDocument.new(edition_factory, document_id, editions)
  }

  let(:document_id)         { "a-document-id" }
  let(:edition_factory)     { double(:edition_factory, call: new_edition) }
  let(:new_edition)         { double(:new_edition, published?: false, assign_attributes: nil) }

  let(:draft_edition)       {
    double(:draft_edition,
      draft?: true,
      published?: false,
      assign_attributes: nil,
      version_number: 1,
    )
  }

  let(:published_edition)   {
    double(:published_edition,
      published?: true,
      draft?: false,
      assign_attributes: nil,
      version_number: 1,
    )
  }

  context "document is new, with no previous editions" do
    let(:editions) { [] }
    let(:attrs)    { { title: "Test title" } }

    describe "#udpate" do
      it "creates the first edition" do
        doc.update(attrs)

        expect(edition_factory).to have_received(:call).with(
          version_number: 1,
          state: "draft",
        )
      end
    end
  end

  context "with one draft edition" do
    let(:editions) { [ draft_edition ] }

    it "is in draft" do
      expect(doc).to be_draft
    end

    it "is not published" do
      expect(doc).not_to be_published
    end

    describe "#update(params)" do
      it "updates the draft edition" do
        doc.update(title: "It is a new title")
        expect(draft_edition).to have_received(:assign_attributes).with(title: "It is a new title")
      end
    end
  end

  context "with one published edition" do
    let(:editions) { [ published_edition ] }

    it "is published" do
      expect(doc).to be_published
    end

    it "is not in draft" do
      expect(doc).not_to be_draft
    end

    describe "#update(params)" do
      let(:params) { {title: "It is a new title"} }

      it "builds a new edition with the new params" do
        doc.update(params)
        expect(edition_factory).to have_received(:call).with(hash_including(params))
      end

      it "builds a new edition with an incremented version number" do
        doc.update(params)
        expect(edition_factory).to have_received(:call).with(hash_including(version_number: 2))
      end

      it "builds a new edition in the 'draft' state" do
        doc.update(params)
        expect(edition_factory).to have_received(:call).with(hash_including(state: 'draft'))
      end

      it "presents the new edition as the latest" do
        doc.update(params)
        expect(doc.latest_edition).to eq(new_edition)
      end

      it "returns self" do
        expect(doc.update(params)).to eq(doc)
      end
    end
  end

  context "with one published edition and one draft edition" do
    let(:editions) { [ published_edition, draft_edition ] }

    it "is published and in draft" do
      expect(doc).to be_draft
      expect(doc).to be_published
    end
  end
end
