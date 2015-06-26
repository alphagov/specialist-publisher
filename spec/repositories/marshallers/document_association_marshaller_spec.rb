require "fast_spec_helper"

require "marshallers/document_association_marshaller"

describe DocumentAssociationMarshaller do

  subject(:marshaller) {
    DocumentAssociationMarshaller.new(
      decorator: decorator,
      manual_specific_document_repository_factory: manual_specific_document_repository_factory,
    )
  }

  let(:decorator) { double(:decorator, call: nil) }
  let(:manual_specific_document_repository_factory) {
    double(
      :manual_specific_document_repository_factory,
      call: document_repository,
    )
  }

  let(:document_repository) {
    double(
      :document_repository,
      fetch: nil,
      store: nil,
    )
  }

  let(:entity) { double(:entity) }
  let(:record) {
    double(
      :record,
      :document_ids => document_ids,
      :"document_ids=" => nil,
      :removed_document_ids => removed_document_ids,
      :"removed_document_ids=" => nil,
    )
  }

  let(:document_id) { double(:document_id) }
  let(:document_ids) { [document_id] }
  let(:document) { double(:document, id: document_id) }
  let(:documents) { [document] }

  let(:removed_document_id) { double(:removed_document_id) }
  let(:removed_document_ids) { [removed_document_id] }
  let(:removed_document) { double(:removed_document, id: removed_document_id) }
  let(:removed_documents) { [removed_document] }

  describe "#load" do
    let(:decorated_entity) { double(:decorated_entity) }

    before do
      allow(document_repository).to receive(:fetch).
        with(document_id).and_return(document)
      allow(document_repository).to receive(:fetch).
        with(removed_document_id).and_return(removed_document)
      allow(decorator).to receive(:call).and_return(decorated_entity)
    end

    it "fetches associated documents and removed documents by ids" do
      marshaller.load(entity, record)

      expect(document_repository).to have_received(:fetch).with(document_id)
      expect(document_repository).to have_received(:fetch).
        with(removed_document_id)
    end

    it "decorates the entity with the attributes" do
      marshaller.load(entity, record)

      expect(decorator).to have_received(:call).
        with(entity, documents: documents, removed_documents: removed_documents)
    end

    it "returns the decorated entity" do
      expect(
        marshaller.load(entity, record)
      ).to eq(decorated_entity)
    end
  end

  describe "#dump" do
    before do
      allow(entity).to receive(:documents).and_return(documents)
      allow(entity).to receive(:removed_documents).and_return(removed_documents)
    end

    it "saves associated documents and removed documents" do
      marshaller.dump(entity, record)

      expect(document_repository).to have_received(:store).with(document)
      expect(document_repository).to have_received(:store).
        with(removed_document)
    end

    it "updates associated document ids on the record" do
      marshaller.dump(entity, record)

      expect(record).to have_received(:document_ids=).with(document_ids)
    end

    it "updates associated removed document ids on the record" do
      marshaller.dump(entity, record)

      expect(record).to have_received(:removed_document_ids=).
        with(removed_document_ids)
    end

    it "returns nil" do
      expect(marshaller.dump(entity, record)).to eq(nil)
    end
  end
end
