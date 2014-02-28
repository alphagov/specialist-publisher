require 'spec_helper'

describe SpecialistDocumentRepository do

  let(:panopticon_api) do
    double(:panopticon_api)
  end

  let(:specialist_document_repository) do
    SpecialistDocumentRepository.new(PanopticonMapping, SpecialistDocumentEdition, panopticon_api, document_factory)
  end

  let(:document_factory) { double(:document_factory, call: document) }

  let(:document_id) { "document-id" }

  let(:document) {
    SpecialistDocument.new(edition_factory, document_id, editions)
  }

  let(:edition_factory) { double(:edition_factory) }
  let(:editions) { [new_draft_edition] }

  let(:new_draft_edition) {
    double(
      :new_draft_edition,
      :title => "Example document about oil reserves",
      :"document_id=" => nil,
      :changed? => true,
      :save => true,
      :published? => false,
      :draft? => true,
      :errors => {},
      :add_error => nil,
      :emergency_publish => nil,
      :version_number => 2,
    )
  }

  let(:published_edition) {
    double(
      :published_edition,
      :title => "Example document about oil reserves",
      :"document_id=" => nil,
      :changed? => false,
      :save => nil,
      :published? => true,
      :draft? => false,
      :version_number => 1,
    )
  }

  describe "#all" do
    before do
      @edition_1, @edition_2 = [2, 1].map do |n|
        edition = FactoryGirl.create(:specialist_document_edition,
                            document_id: "document-id-#{n}",
                            updated_at: n.days.ago)

        allow(document_factory).to receive(:call)
          .with("document-id-#{n}", [edition])
          .and_return(SpecialistDocument.new(edition_factory, "document-id-#{n}", [edition]))

        edition
      end
    end

    it "returns all documents by date updated desc" do
      specialist_document_repository.all.map(&:title).should == [@edition_2, @edition_1].map(&:title)
    end
  end

  describe "#fetch" do
    let(:editions_proxy) { double(:editions_proxy, to_a: editions) }
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
       allow(SpecialistDocumentEdition).to receive(:where)
        .with(document_id: document_id)
        .and_return([])
      end

      it "returns nil" do
        expect(specialist_document_repository.fetch(document_id)).to be(nil)
      end
    end
  end

  context "when the document is new" do
    before do
      @document = SpecialistDocument.new(edition_factory, document_id, [new_draft_edition])
      @panopticon_id = 'some-panopticon-id'
      allow(panopticon_api).to receive(:create_artefact!).and_return('id' => @panopticon_id)
    end

    describe "#store!(document)" do
      it "creates a draft artefact" do
        panopticon_api.should_receive(:create_artefact!).with(
          hash_including(
            slug: @document.slug,
            name: @document.title,
            state: 'draft',
            owning_app: 'specialist-publisher',
            rendering_app: 'specialist-frontend',
            paths: ["/#{@document.slug}"],
          )
        )

        specialist_document_repository.store!(@document)
      end

      it "stores a mapping of document id to panopticon id" do
        specialist_document_repository.store!(@document)

        mapping = PanopticonMapping.where(document_id: @document.id).last
        expect(mapping.panopticon_id).to eq(@panopticon_id)
      end
    end

    describe "#publish!(document)" do
      it "raises an InvalidDocumentError" do
        expect { specialist_document_repository.publish!(@document) }.to raise_error(SpecialistDocumentRepository::InvalidDocumentError)
      end
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
    before do
      allow(panopticon_api).to receive(:create_artefact!).and_return({'id' => panopticon_id})
    end

    let(:panopticon_id) { 'some-panopticon-id' }

    let(:latest_edition) { new_draft_edition }
    let(:previous_edition) { published_edition }

    let(:editions) { [previous_edition, latest_edition] }

    it "returns true" do
      expect(specialist_document_repository.store!(document)).to be true
    end

    it "only saves the latest edition" do
      specialist_document_repository.store!(document)

      expect(latest_edition).to have_received(:save)
      expect(previous_edition).not_to have_received(:save)
    end
  end
end

  context "when the document exists in draft" do
    before do
      draft_edition = FactoryGirl.create(:specialist_document_edition, document_id: document_id, state: 'draft')
      @document = SpecialistDocument.new(edition_factory, '12345', [draft_edition])
      @mapping = FactoryGirl.create(:panopticon_mapping, document_id: @document.id)
      allow(panopticon_api).to receive(:put_artefact!)
    end

    describe "#publish!(document)" do
      it "the document becomes published" do
        specialist_document_repository.publish!(@document)
        @document.should be_published
      end

      it "notifies panopticon of the update" do
        specialist_document_repository.publish!(@document)
        expect(panopticon_api).to have_received(:put_artefact!).with(@mapping.panopticon_id, anything)
      end
    end
  end

  context "when the document exists and is published" do
    before do
      @document = SpecialistDocument.new(edition_factory, '12345', [published_edition])
      @mapping = FactoryGirl.create(:panopticon_mapping, document_id: @document.id)
    end

    describe "#publish!(document)" do
      it "does not notify panopticon of the update" do
        panopticon_api.should_not_receive(:put_artefact!)
        specialist_document_repository.publish!(@document)
      end
    end
  end

  context "when panopticon raises an exception, eg duplicate slug" do
    before do
      exception = GdsApi::HTTPErrorResponse.new(422, 'errors' => {slug: ['already taken']})
      allow(panopticon_api).to receive(:create_artefact!).and_raise(exception)
    end

    describe "#store!" do
      let(:editions) { [new_draft_edition] }

      it "sets error messages on the document" do
        new_draft_edition.should_receive(:add_error).with(:slug, include('already taken'))
        specialist_document_repository.store!(document)
      end

      it "returns false" do
        specialist_document_repository.store!(document).should == false
      end
    end
  end
end
