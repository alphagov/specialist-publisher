require "fast_spec_helper"
require "publish_document_service"
RSpec.describe PublishDocumentService do
  let(:document_id) { double(:document_id) }
  let(:repository) { double(:repository) }
  let(:latest_edition) { double(:latest_edition) }
  let(:published_edition) { double(:published_edition) }
  let(:document) {
    double(:document,
      minor_update: minor_update,
      extra_fields: {bulk_published: false},
      latest_edition: latest_edition,
      published_edition: published_edition,
    )
  }
  let(:minor_update) { nil }
  let(:listeners) { [] }

  subject {
    PublishDocumentService.new(
      repository,
      listeners,
      document_id,
      bulk_publish,
    )
  }

  before do
    allow(repository).to receive(:fetch) { document }
    allow(repository).to receive(:store)
    allow(document).to receive(:update)
    allow(document).to receive(:publish!)
  end

  shared_examples_for "a document publication" do
    it "publishes the document" do
      subject.call
      expect(document).to have_received(:publish!)
    end
  end

  context "when using normally" do
    let(:bulk_publish) { false }
    it_behaves_like "a document publication"

    let(:time) { double(:time) }

    before do
      allow(Time).to receive(:current).and_return(time)
    end

    it "clears bulk published" do
      subject.call

      expect(document).to have_received(:update).with({bulk_published: false})
    end

    it "sets public_updated_at to current time" do
      subject.call

      expect(document).to have_received(:update).with({public_updated_at: time})
    end

    context "on a minor update" do
      let(:minor_update) { true }

      it "does not clear bulk published or update the public_updated_at" do
        subject.call
        expect(document).not_to have_received(:update)
      end
    end
  end

  context "when bulk publishing" do
    let(:bulk_publish) { true }
    it_behaves_like "a document publication"

    let(:time) { double(:time) }

    before do
      allow(Time).to receive(:current).and_return(time)
    end

    it "sets bulk published" do
      subject.call
      expect(document).to have_received(:update).with({bulk_published: true})
    end

    it "does sets the public_updated_at" do
      subject.call
      expect(document).to have_received(:update).with({public_updated_at: time})
    end
  end
end
