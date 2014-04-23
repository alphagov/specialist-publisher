require 'spec_helper'

describe SpecialistDocumentRepository do

  let(:panopticon_api) do
    double(:panopticon_api)
  end

  let(:panopticon_mappings) { PanopticonMapping }

  let(:publication_observers) { [publication_observer] }
  let(:publication_observer)  { double(:publication_observer, call: nil) }

  let(:specialist_document_repository) do
    SpecialistDocumentRepository.new(
      panopticon_mappings,
      SpecialistDocumentEdition,
      panopticon_api,
      document_factory,
      publication_observers,
    )
  end

  let(:document_factory) { double(:document_factory, call: document) }

  let(:document_id) { "document-id" }

  let(:document) {
    SpecialistDocument.new(slug_generator, edition_factory, document_id, editions)
  }

  let(:slug_generator) { double(:slug_generator) }

  let(:edition_factory) { double(:edition_factory) }
  let(:editions) { [new_draft_edition] }

  let(:new_draft_edition) {
    double(
      :new_draft_edition,
      :title => "Example document about oil reserves",
      :slug => "example-document-about-oil-reserves",
      :"document_id=" => nil,
      :"slug=" => nil,
      :changed? => true,
      :save => true,
      :published? => false,
      :draft? => true,
      :errors => {},
      :publish => nil,
      :version_number => 2,
      :archive => nil,
    )
  }

  def build_published_edition(version: 1)
    double(
      :published_edition,
      :title => "Example document about oil reserves #{version}",
      :"document_id=" => nil,
      :changed? => false,
      :save => nil,
      :archive => nil,
      :published? => true,
      :draft? => false,
      :version_number => version,
    )
  end

  def build_specialist_document(*args)
    SpecialistDocument.new(slug_generator, edition_factory, *args)
  end

  let(:published_edition) { build_published_edition }

  describe "#all" do
    before do
      @edition_1, @edition_2 = [2, 1].map do |n|
        document_id = "document-id-#{n}"

        edition = FactoryGirl.create(:specialist_document_edition,
                            document_id: document_id,
                            updated_at: n.days.ago)

        allow(document_factory).to receive(:call)
          .with(document_id, [edition])
          .and_return(build_specialist_document(document_id, [edition]))

        edition
      end

      allow(panopticon_mappings).to receive(:all_document_ids)
        .and_return([@edition_1.document_id, @edition_2.document_id])
    end

    it "returns all documents by date updated desc" do
      specialist_document_repository.all.map(&:title).should == [@edition_2, @edition_1].map(&:title)
    end
  end

  describe "#fetch" do
    let(:editions_proxy) { double(:editions_proxy, to_a: editions).as_null_object }
    let(:editions)       { [ published_edition ] }

    before do
      allow(SpecialistDocument).to receive(:new).and_return(document)
      allow(SpecialistDocumentEdition).to receive(:where)
        .with(document_id: document_id)
        .and_return(editions_proxy)
    end

    it "populates the document with all editions for that document id" do
      specialist_document_repository.fetch(document_id)

      expect(document_factory).to have_received(:call).with(document_id, editions)
    end

    it "returns the document" do
      expect(specialist_document_repository.fetch(document_id)).to eq(document)
    end

    context "when there are no editions" do
      before do
        allow(editions_proxy).to receive(:to_a).and_return([])
      end

      it "returns nil" do
        expect(specialist_document_repository.fetch(document_id)).to be(nil)
      end
    end
  end

  context "when the document is new" do
    before do
      @document = build_specialist_document(document_id, [new_draft_edition])
    end
  end

  describe "#store!(document)" do
    context "with an invalid document" do
      before do
        allow(new_draft_edition).to receive(:save).and_return(false)
      end

      it "returns false" do
        expect(specialist_document_repository.store!(document)).to be false
      end
    end

    context "with a valid document" do
      let(:previous_edition) { published_edition }

      let(:editions) { [previous_edition, new_draft_edition] }

      it "returns true" do
        expect(specialist_document_repository.store!(document)).to be true
      end

      it "assigns the document_id edition" do
        specialist_document_repository.store!(document)

        expect(new_draft_edition).to have_received(:document_id=).with(document_id)
      end

      it "only saves the latest edition" do
        specialist_document_repository.store!(document)

        expect(new_draft_edition).to have_received(:save)
        expect(previous_edition).not_to have_received(:save)
      end
    end
  end
end
