require "support/fast_spec_helper"

require "specialist_document_exporter"

describe SpecialistDocumentExporter do
  subject(:exporter) {
    SpecialistDocumentExporter.new(
      export_recipent,
      document_renderer,
      document,
    )
  }

  let(:export_recipent) { double(:export_recipent, create_or_update_by_slug!: nil) }
  let(:document) { double(:document) }
  let(:document_id) { double(:document_id) }

  let(:document_renderer) {
    double(:document_renderer, call: rendered_document)
  }

  let(:rendered_document) {
    double(:rendered_document, attributes: rendered_attributes)
  }

  let(:rendered_attributes) {
    {
      id: document_id,
    }.merge(exportable_attributes)
  }

  let(:exportable_attributes) {
    {
      a_field: "a value",
    }
  }

  it "renders the document" do
    exporter.call

    expect(document_renderer).to have_received(:call).with(document)
  end

  it "exports the serialized document attributes" do
    exporter.call

    expect(export_recipent).to have_received(:create_or_update_by_slug!).with(
      hash_including(exportable_attributes)
    )
  end

  it "translates the id field to document id" do
    exporter.call

    expect(export_recipent).to have_received(:create_or_update_by_slug!).with(
      hash_including(document_id: document_id)
    )

    expect(export_recipent).to have_received(:create_or_update_by_slug!).with(
      hash_excluding(id: document_id)
    )
  end
end
