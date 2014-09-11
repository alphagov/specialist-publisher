require "fast_spec_helper"

require "manual_publishing_api_exporter"

describe ManualPublishingAPIExporter do
  subject {
    ManualPublishingAPIExporter.new(
      export_recipent,
      organisations_api,
      manual_renderer,
      publication_logs_collection,
      manual
    )
  }

  let(:export_recipent) { double(:export_recipent, put_content_item: nil) }
  let(:organisations_api) {
    double(
      :organisations_api,
      organisation: organisation,
    )
  }
  let(:manual_renderer) { ->(_) { double(:rendered_manual, attributes: manual_attributes) } }

  let(:manual) {
    double(
      :manual,
      attributes: manual_attributes,
      documents: documents,
    )
  }

  let(:manual_slug) { "guidance/my-first-manual" }

  let(:documents) {
    [
      double(
        :document,
        attributes: document_attributes,
        minor_update?: false,
      )
    ]
  }

  let(:document_attributes) {
    {
      title: "Document title",
      summary: "This is the first section",
      slug: "#{manual_slug}/first-section",
    }
  }

  let(:organisation) {
    double(:organisation,
      web_url: "https://www.gov.uk/government/organisations/cabinet-office",
      title: "Cabinet Office",
      details: double(:org_details, abbreviation: "CO"),
    )
  }

  let(:manual_attributes) {
    {
      id: "12345",
      title: "My first manual",
      summary: "This is my first manual",
      body: "<h1>Some heading</h1>\nmanual body",
      slug: "guidance/my-first-manual",
      updated_at: Date.new(2013, 12, 31),
      organisation_slug: "cabinet-office",
    }
  }

  let(:publication_logs_collection) {
    double(:publication_logs, change_notes_for: publication_logs)
  }

  let(:publication_logs) {
    [
      double(
        :publication_log,
        slug: "guidance/my-first-manual/first-section",
        title: "Document title",
        change_note: "Added more text",
        published_at: Time.new(2013, 12, 31, 12, 0, 0),
      ),
      double(
        :publication_log,
        slug: "guidance/my-first-manual",
        title: "My manual",
        change_note: "Changed manual title",
        published_at: Time.new(2013, 12, 31, 12, 30, 0),
      ),
    ]
  }

  it "exports the serialized document attributes" do
    subject.call

    expect(export_recipent).to have_received(:put_content_item).with(
      "/guidance/my-first-manual",
      hash_including(
        base_path: "/guidance/my-first-manual",
        format: "manual",
        title: "My first manual",
        description: "This is my first manual",
        public_updated_at: Date.new(2013, 12, 31),
        update_type: "major",
        publishing_app: "specialist-publisher",
        rendering_app: "manuals-frontend",
        routes: [
          {
            path: "/guidance/my-first-manual",
            type: "exact",
          }
        ],
      ))
  end

  it "exports section metadata for the manual" do
    subject.call

    expect(export_recipent).to have_received(:put_content_item).with(
      "/guidance/my-first-manual",
      hash_including(
        details: {
          body: "<h1>Some heading</h1>\nmanual body",
          child_section_groups: [
            {
              title: "Contents",
              child_sections: [
                base_path: "/guidance/my-first-manual/first-section",
                title: "Document title",
                description: "This is the first section",
              ]
            }
          ],
          change_notes: [
            {
              base_path: "/guidance/my-first-manual/first-section",
              title: "Document title",
              change_note: "Added more text",
              published_at: Time.new(2013, 12, 31, 12, 0, 0),
            },
            {
              base_path: "/guidance/my-first-manual",
              title: "My manual",
              change_note: "Changed manual title",
              published_at: Time.new(2013, 12, 31, 12, 30, 0),
            },
          ],
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
