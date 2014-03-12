require "support/fast_spec_helper"

require "specialist_document_database_exporter"

describe SpecialistDocumentDatabaseExporter do
  subject(:exporter) {
    SpecialistDocumentDatabaseExporter.new(
      active_record,
      document_renderer,
      document,
    )
  }

  let(:active_record) { double(:active_record, create!: nil) }
  let(:document) { double(:document) }

  let(:document_renderer) {
    double(:document_renderer, call: rendered_document)
  }

  let(:rendered_document) {
    double(:rendered_document, attributes: rendered_attributes)
  }

  let(:rendered_attributes) { double(:rendered_attributes) }

  it "renders the document" do
    exporter.call

    expect(document_renderer).to have_received(:call).with(document)
  end

  it "writes the serialized document attributes to the database" do
    exporter.call

    expect(active_record).to have_received(:create!).with(rendered_attributes)
  end
end
