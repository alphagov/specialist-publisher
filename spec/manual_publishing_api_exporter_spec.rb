require "fast_spec_helper"

require "manual_publishing_api_exporter"

describe ManualPublishingAPIExporter do
  subject {
    ManualPublishingAPIExporter.new(export_recipent, manual)
  }

  let(:export_recipent) { double(:export_recipent, put_content_item: nil) }
  let(:manual) {
    double(
      :manual,
      attributes: manual_attributes,
      documents: documents
    )
  }

  let(:manual_slug) { "guidance/my-first-manual" }

  let(:documents) {
    [
      double(
        :document,
        title: "Document title",
        summary: "This is the first section",
        slug: "#{manual_slug}/first-section",
      )
    ]
  }

  let(:manual_attributes) {
    {
      id: "12345",
      title: "My first manual",
      summary: "This is my first manual",
      slug: "guidance/my-first-manual",
      updated_at: Date.new(2013, 12, 31),
    }
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
          child_section_groups: [
            {
              title: "Contents",
              child_sections: [
                base_path: "/guidance/my-first-manual/first-section",
                title: "Document title",
                description: "This is the first section",
              ]
            }
          ]
        }
      )
    )
  end
end
