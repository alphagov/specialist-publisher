require "support/fast_spec_helper"

require "specialist_document_exporter"

describe SpecialistDocumentExporter do
  subject(:exporter) {
    SpecialistDocumentExporter.new(
      export_recipent,
      document_renderer,
      finder_schema,
      document,
    )
  }

  let(:export_recipent) { double(:export_recipent, create_or_update_by_slug!: nil) }
  let(:document_renderer) { double(:document_renderer, call: rendered_document) }
  let(:finder_schema) {
    double(:finder_schema, facets: [:case_type]).tap do |f|
      allow(f).to receive(:options_for).with(:case_type).and_return([["CA98 and civil cartels", "ca98-and-civil-cartels"]])
    end
  }
  let(:document) { double(:document) }

  let(:rendered_document) {
    double(:rendered_document, attributes: rendered_attributes)
  }

  let(:document_id) { double(:document_id) }

  let(:rendered_attributes) {
    {
      id: document_id,
      case_type: "ca98-and-civil-cartels"
    }
  }

  it "renders the document" do
    exporter.call

    expect(document_renderer).to have_received(:call).with(document)
  end

  it "exports the serialized document attributes" do
    exporter.call

    expect(export_recipent).to have_received(:create_or_update_by_slug!).with(
      hash_including(case_type: "ca98-and-civil-cartels")
    )
  end

  it "exports both labels and values for filterable options" do
    exporter.call

    expect(export_recipent).to have_received(:create_or_update_by_slug!).with(
      hash_including(
        case_type: "ca98-and-civil-cartels",
        case_type_label: "CA98 and civil cartels"
      )
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
