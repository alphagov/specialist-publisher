require "fast_spec_helper"

require "manual_section_publishing_api_exporter"

describe ManualSectionPublishingAPIExporter do
  subject {
    ManualSectionPublishingAPIExporter.new(
      export_recipent,
      organisations_api,
      document_renderer,
      manual,
      document
    )
  }

  let(:export_recipent) { double(:export_recipent, put_content_item: nil) }
  let(:organisations_api) {
    double(
      :organisations_api,
      organisation: organisation,
    )
  }
  let(:document_renderer) { ->(_) { double(:rendered_document, attributes: rendered_attributes) } }

  let(:organisation) {
    double(:organisation,
      web_url: "https://www.gov.uk/government/organisations/cabinet-office",
      title: "Cabinet Office",
      details: double(:org_details, abbreviation: "CO"),
    )
  }

  let(:manual) {
    double(
      :manual,
      attributes: {
        slug: manual_slug,
        organisation_slug: "cabinet-office",
      },
    )
  }

  let(:manual_slug) { "guidance/my-first-manual" }

  let(:document) {
    double(
      :document,
      minor_update?: true,
    )
  }

  let(:rendered_attributes) {
    {
      title: "Document title",
      summary: "This is the first section",
      slug: "guidance/my-first-manual/first-section",
      body: "<h1>Some heading</h1>\nsection body",
      updated_at: Date.new(2013, 12, 31),
    }
  }

  it "exports the serialized document attributes" do
    subject.call

    expect(export_recipent).to have_received(:put_content_item).with(
      "/guidance/my-first-manual/first-section",
      hash_including(
        base_path: "/guidance/my-first-manual/first-section",
        format: "manual_section",
        title: "Document title",
        description: "This is the first section",
        public_updated_at: Date.new(2013, 12, 31),
        update_type: "minor",
        publishing_app: "specialist-publisher",
        rendering_app: "manuals-frontend",
        routes: [
          {
            path: "/guidance/my-first-manual/first-section",
            type: "exact",
          }
        ],
      ))
  end

  it "exports section metadata for the document" do
    subject.call

    expect(export_recipent).to have_received(:put_content_item).with(
      "/guidance/my-first-manual/first-section",
      hash_including(
        details: {
          body: "<h1>Some heading</h1>\nsection body",
          manual: {
            base_path: "/guidance/my-first-manual",
          },
          child_section_groups: [],
          breadcrumbs: [],
          organisations: [
            {
              title: "Cabinet Office",
              abbreviation: "CO",
              web_url: "https://www.gov.uk/government/organisations/cabinet-office",
            }
          ],
        }
      )
    )
  end
end
