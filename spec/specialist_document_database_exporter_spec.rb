require "fast_spec_helper"

require "specialist_document_database_exporter"

describe SpecialistDocumentDatabaseExporter do
  subject(:exporter) {
    SpecialistDocumentDatabaseExporter.new(
      export_recipent,
      document_renderer,
      finder_schema,
      document,
      publication_logs,
    )
  }

  let(:document_slug) { double(:document_slug) }
  let(:publication_logs) { double(:publication_logs, change_notes_for: []) }
  let(:export_recipent) { double(:export_recipent, create_or_update_by_slug!: nil) }
  let(:document_renderer) { double(:document_renderer, call: rendered_document) }
  let(:finder_schema) {
    double(:finder_schema, facets: [:case_type]).tap do |f|
      allow(f).to receive(:options_for).with(:case_type).and_return([["CA98 and civil cartels", "ca98-and-civil-cartels"]])
    end
  }

  let(:previous_major_updated_at) { double(:previous_major_updated_at) }
  let(:newly_published_time) { double(:newly_published_time) }
  let(:document) {
    double(:document,
      slug: document_slug,
      minor_update?: false,
      previous_major_updated_at: previous_major_updated_at,
      updated_at: newly_published_time,
    )
  }

  let(:rendered_document) {
    double(
      :rendered_document,
      attributes: rendered_document_attributes,
      case_type: case_type,
    )
  }

  let(:case_type)  { "ca98-and-civil-cartels" }

  let(:rendered_document_attributes) {
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
      headers: header_metadata,
    }
  }

  let(:schema_defined_attributes) {
    {
      case_type: case_type,
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
          change_history: []
        }
      )
    )
  end

  it "exports change notes if there are any in the details hash" do
    published_at = Time.now
    publication_log_entry = double(:publication_log,
      change_note: "Change is good!",
      published_at: published_at
    )
    allow(publication_logs).to receive(:change_notes_for).with(document_slug)
                                                          .and_return([publication_log_entry])

    exporter.call
    expect(export_recipent).to have_received(:create_or_update_by_slug!).with(
      hash_including(
        details: hash_including(
          change_history: [
            {
              note: "Change is good!",
              published_timestamp: published_at.utc,
            }
          ]
        )
      )
    )
  end
end
