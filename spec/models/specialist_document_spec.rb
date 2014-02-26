require 'spec_helper'

describe SpecialistDocument do
  subject(:doc) {
    SpecialistDocument.new(document_id, editions)
  }

  let(:document_id)         { "a-document-id" }

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
      let(:new_edition) { double }

      before do
        SpecialistDocumentEdition.stub(:new).and_return(new_edition)
      end

      it "builds a new edition with the new params" do
        doc.update(params)
        expect(SpecialistDocumentEdition).to have_received(:new).with(hash_including(params))
      end

      it "builds a new edition with an incremented version number" do
        doc.update(params)
        expect(SpecialistDocumentEdition).to have_received(:new).with(hash_including(version_number: 2))
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
