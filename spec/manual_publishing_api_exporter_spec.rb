require "fast_spec_helper"
require "support/govuk_content_schema_helpers"

require "manual_publishing_api_exporter"

describe ManualPublishingAPIExporter do
  subject {
    ManualPublishingAPIExporter.new(
      export_recipent,
      organisation,
      manual_renderer,
      publication_logs_collection,
      manual
    )
  }

  let(:export_recipent) { double(:export_recipent, call: nil) }
  let(:manual_renderer) { ->(_) { double(:rendered_manual, attributes: manual_attributes) } }

  let(:manual) {
    double(
      :manual,
      id: "52ab9439-95c8-4d39-9b83-0a2050a0978b",
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
      title: "My first manual",
      summary: "This is my first manual",
      body: "<h1>Some heading</h1>\nmanual body",
      slug: "guidance/my-first-manual",
      updated_at: Time.new(2013, 12, 31, 12, 0, 0),
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

  it "exports a manual valid against the schema" do
    expect(subject.send(:exportable_attributes).to_json).to be_valid_against_schema("manual")
  end

  it "exports the serialized document attributes" do
    subject.call

    expect(export_recipent).to have_received(:call).with(
      "/guidance/my-first-manual",
      hash_including(
        content_id: "52ab9439-95c8-4d39-9b83-0a2050a0978b",
        format: "manual",
        title: "My first manual",
        description: "This is my first manual",
        public_updated_at: Time.new(2013, 12, 31, 12, 0, 0).iso8601,
        update_type: "major",
        publishing_app: "specialist-publisher",
        rendering_app: "manuals-frontend",
        routes: [
          {
            path: "/guidance/my-first-manual",
            type: "exact",
          },
          {
            path: "/guidance/my-first-manual/updates",
            type: "exact",
          }
        ],
        locale: "en",
      ))
  end

  it "exports section metadata for the manual" do
    subject.call

    expect(export_recipent).to have_received(:call).with(
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
              published_at: Time.new(2013, 12, 31, 12, 0, 0).iso8601,
            },
            {
              base_path: "/guidance/my-first-manual",
              title: "My manual",
              change_note: "Changed manual title",
              published_at: Time.new(2013, 12, 31, 12, 30, 0).iso8601,
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
