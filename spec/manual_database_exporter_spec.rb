require "fast_spec_helper"

require "manual_database_exporter"

describe ManualDatabaseExporter do
  subject(:exporter) {
    ManualDatabaseExporter.new(
      export_recipent,
      manual,
    )
  }

  let(:export_recipent) { double(:export_recipent, create_or_update_by_slug!: nil) }
  let(:manual) {
    double(
      :manual,
      attributes: manual_attributes,
      documents: documents
    )
  }

  let(:rendered_manual) {
    double(:rendered_manual, attributes: rendered_attributes)
  }

  let(:manual_id) { double(:manual_id) }
  let(:manual_title) { double(:manual_title) }
  let(:manual_summary) { double(:manual_summary) }
  let(:manual_slug) { double(:manual_slug) }

  let(:documents) { [document] }
  let(:document) {
    double(
      :document,
      title: document_title,
      summary: document_summary,
      slug: document_slug,
    )
  }

  let(:document_title) { double(:document_title) }
  let(:document_summary) { double(:document_summary) }
  let(:document_slug) { double(:document_slug) }

  let(:manual_attributes) {
    {
      id: manual_id,
      title: manual_title,
      summary: manual_summary,
      slug: manual_slug,
    }
  }

  it "exports the serialized document attributes" do
    exporter.call

    expect(export_recipent).to have_received(:create_or_update_by_slug!)
      .with(hash_including(
        title: manual_title,
        summary: manual_summary,
        slug: manual_slug,
      ))
  end

  it "exports section metadata for the manual" do
    exporter.call

    expect(export_recipent).to have_received(:create_or_update_by_slug!).with(
      hash_including(
        section_groups: [
          {
            title: "Contents",
            sections: [
              title: document_title,
              summary: document_summary,
              slug: document_slug,
            ]
          }
        ]
      )
    )
  end
end
