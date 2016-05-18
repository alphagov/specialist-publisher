require 'spec_helper'

RSpec.describe Document do
  class MyDocumentType < Document
    def self.title
      "My Document Type"
    end

    attr_accessor :field1, :field2, :field3

    def initialize(params = {})
      super(params, [:field1, :field2, :field3])
    end
  end

  it "has a document_type for building URLs" do
    expect(MyDocumentType.slug).to eq("my-document-types")
  end

  it "has a document_type for fetching params of the format" do
    expect(MyDocumentType.document_type).to eq("my_document_type")
  end

  describe ".all" do
    it "makes a request to the publishing api with the correct params" do
      publishing_api = double(:publishing_api)
      allow(Services).to receive(:publishing_api).and_return(publishing_api)

      expect(publishing_api).to receive(:get_content_items)
        .with(
          document_type: "my_document_type",
          fields: [
            :base_path,
            :content_id,
            :updated_at,
            :title,
            :publication_state,
          ],
          page: 1,
          per_page: 20,
          order: "-updated_at",
          q: "foo",
        )

      MyDocumentType.all(1, 20, q: "foo")
    end
  end

  let(:finder_schema) {
    {
      base_path: "/my-document-types",
      filter: {
        document_type: "my_document_type",
      }
    }.deep_stringify_keys
  }

  let(:payload) {
    FactoryGirl.create(:document,
      document_type: "my_document_type",
      title: "Example document",
      description: "This is a summary",
      base_path: "/my-document-types/example-document",
      details: {
        body: [
          {
            content_type: "text/govspeak",
            content: "## Header" + ("\r\n\r\nThis is the long body of an example document" * 10),
          },
          {
            content_type: "text/html",
            content: ("<h2 id=\"header\">Header</h2>\n" + "\n<p>This is the long body of an example document</p>\n" * 10),
          },
        ],
        metadata: {
          field1: "2015-12-01",
          field2: "open",
          field3: %w(x y z),
          document_type: "my_document_type",
          bulk_published: true,
        }
      })
  }
  let(:document) { MyDocumentType.from_publishing_api(payload) }

  before do
    allow_any_instance_of(FinderSchema).to receive(:load_schema_for).with("my_document_types").
      and_return(finder_schema)
  end

  context "successful #publish!" do
    before do
      stub_publishing_api_publish(document.content_id, {})
      stub_any_rummager_post_with_queueing_enabled
      @email_alert_api = email_alert_api_accepts_alert
    end

    it "sends a payload to Publishing API" do
      expect(document.publish!).to eq(true)

      assert_publishing_api_publish(document.content_id)
    end

    it "sends a payload to Rummager" do
      expect(document.publish!).to eq(true)

      assert_rummager_posted_item(
        "title" => "Example document",
        "description" => "This is a summary",
        "indexable_content" => "Header " + (["This is the long body of an example document"] * 10).join(" "),
        "link" => "/my-document-types/example-document",
        "public_timestamp" => "2015-11-16T11:53:30+00:00",
        "field1" => "2015-12-01",
        "field2" => "open",
      )
    end

    it "alerts the email API for major updates" do
      document.update_type = "major"

      expect(document.publish!).to eq(true)

      assert_email_alert_sent(
        "tags" => {
          "format" => "my_document_type",
          "field1" => "2015-12-01",
          "field2" => "open",
          "field3" => %w(x y z),
        },
        "document_type" => "my_document_type"
      )
    end

    it "doesn't alerts the email API for minor updates" do
      document.update_type = "minor"

      expect(document.publish!).to eq(true)

      expect(@email_alert_api).to_not have_been_requested
    end
  end

  describe "#save!" do
    before do
      publishing_api_has_item(payload)
      Timecop.freeze(Time.parse("2015-12-18 10:12:26 UTC"))
    end

    it "saves document" do
      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links

      c = MyDocumentType.find(payload["content_id"])
      expect(c.save!).to eq(true)

      expected_payload = write_payload(payload.deep_stringify_keys).deep_merge(
        "public_updated_at" => "2015-12-18T10:12:26+00:00",
        "details" => {
          "change_history" => [
            {
              "public_timestamp" => "2015-12-18T10:12:26+00:00",
              "note" => "First published.",
            }
          ]
        }
      )
      assert_publishing_api_put_content(c.content_id, expected_payload)
    end
  end

  def write_payload(document)
    document.delete("updated_at")
    document.delete("publication_state")
    document
  end
end
