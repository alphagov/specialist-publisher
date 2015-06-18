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
    )
  }

  let(:document_id) { double(:document_id) }
  let(:document_ids) { [document_id] }
  let(:document) { double(:document, id: document_id) }
  let(:documents) { [document] }

  describe "#load" do
    let(:decorated_entity) { double(:decorated_entity) }

    before do
      allow(document_repository).to receive(:fetch).and_return(document)
      allow(decorator).to receive(:call).and_return(decorated_entity)
    end

    it "fetches associated documents by ids" do
      marshaller.load(entity, record)

      expect(document_repository).to have_received(:fetch).with(document_id)
    end

    it "decorates the entity with the documents" do
      marshaller.load(entity, record)

      expect(decorator).to have_received(:call)
        .with(entity, documents: documents)
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
    end

    it "saves associated documents" do
      marshaller.dump(entity, record)

      expect(document_repository).to have_received(:store).with(document)
    end

    it "updates associated document ids on the record" do
      marshaller.dump(entity, record)

      expect(record).to have_received(:document_ids=).with(document_ids)
    end

    it "returns nil" do
      expect(marshaller.dump(entity, record)).to eq(nil)
    end
  end
end
