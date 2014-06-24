require "fast_spec_helper"

require "specialist_document_database_exporter"

describe SpecialistDocumentDatabaseExporter do
  subject(:exporter) {
    SpecialistDocumentDatabaseExporter.new(
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
    double(:rendered_document, rendered_document_messages)
  }

  let(:rendered_document_messages) {
    core_rendered_attributes
      .merge(schema_defined_attributes)
      .merge(other_rendered_attributes)
  }

  let(:core_rendered_attributes) {
    {
      slug: "/cma-cases/o-hai",
      title: "O HAI",
      summary: "A funny",
      body: "<p>LOL</p>",
    }
  }

  let(:other_rendered_attributes) {
    {
      id: "document_id",
      serialized_headers: header_metadata,
    }
  }

  let(:schema_defined_attributes) {
    {
      case_type: "ca98-and-civil-cartels",
    }
  }

  let(:header_metadata) { double(:header_metadata) }

  it "renders the document" do
    exporter.call

    expect(document_renderer).to have_received(:call).with(document)
  end

  it "exports the core rendered document attributes" do
    exporter.call

    expect(export_recipent).to have_received(:create_or_update_by_slug!)
      .with(hash_including(core_rendered_attributes))
  end

  it "filters undesirable attributes from the export" do
    exporter.call

    expect(export_recipent).to have_received(:create_or_update_by_slug!)
      .with(hash_excluding(other_rendered_attributes))
  end

  it "exports all the 'details', schema defined facets, labels and headers" do
    exporter.call

    expect(export_recipent).to have_received(:create_or_update_by_slug!).with(
      hash_including(
        details: {
          case_type: "ca98-and-civil-cartels",
          case_type_label: "CA98 and civil cartels",
          headers: header_metadata,
        }
      )
    )
  end
end
