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

  context "unsuccessful #publish!" do
    it "notifies Airbrake and returns false if publishing-api does not return status 200" do
      expect(Airbrake).to receive(:notify)
      stub_publishing_api_publish(document.content_id, {}, status: 503)
      stub_any_rummager_post_with_queueing_enabled
      expect(document.publish!).to eq(false)
    end

    it "notifies Airbrake and returns false if rummager does not return status 200" do
      expect(Airbrake).to receive(:notify)
      stub_publishing_api_publish(document.content_id, {})
      stub_request(:post, %r{#{Plek.new.find('search')}/documents}).to_return(status: 503)
      expect(document.publish!).to eq(false)
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

  describe ".find" do
    it "returns a document" do
      publishing_api_has_item(payload)

      found_document = MyDocumentType.find(document.content_id)

      expect(found_document.base_path).to eq(payload["base_path"])
      expect(found_document.title).to     eq(payload["title"])
      expect(found_document.summary).to   eq(payload["description"])
      expect(found_document.body).to      eq(payload["details"]["body"][0]["content"])
      expect(found_document.field3).to    eq(payload["details"]["metadata"]["field3"])
    end
  end

  context "with attachments" do
    let(:payload) {
      FactoryGirl.create(:document,
        document_type: "my_document_type",
        details: {
          "metadata" => {
            "document_type" => "my_document_type"
          },
          "attachments" => [
            {
              "content_id" => "77f2d40e-3853-451f-9ca3-a747e8402e34",
              "url" => "https://assets.digital.cabinet-office.gov.uk/media/513a0efbed915d425e000002/asylum-support-image.jpg",
              "content_type" => "application/jpeg",
              "title" => "asylum report image title",
              "created_at" => "2015-12-18T10:12:26+00:00",
              "updated_at" => "2015-12-18T10:12:26+00:00"
            },
            {
              "content_id" => "ec3f6901-4156-4720-b4e5-f04c0b152141",
              "url" => "https://assets.digital.cabinet-office.gov.uk/media/513a0efbed915d425e000002/asylum-support-pdf.pdf",
              "content_type" => "application/pdf",
              "title" => "asylum report pdf title",
              "created_at" => "2015-12-18T10:12:26+00:00",
              "updated_at" => "2015-12-18T10:12:26+00:00"
            }
          ]
        })
    }

    before do
      Timecop.freeze(Time.parse("2016-01-30 10:12:26 UTC"))
    end

    it "re-sends attachments to the Publishing API with updated timestamps" do
      document = MyDocumentType.from_publishing_api(payload)
      presented_document = DocumentPresenter.new(document).to_json.deep_stringify_keys

      expect(presented_document["details"]["attachments"]).to eq([
        payload["details"]["attachments"][0].merge("updated_at" => "2016-01-30T10:12:26+00:00"),
        payload["details"]["attachments"][1].merge("updated_at" => "2016-01-30T10:12:26+00:00"),
      ])
    end

    describe "#find_attachment" do
      it "finds an attachment object in the document payload" do
        attachment_content_id = payload["details"]["attachments"][0]["content_id"]
        document = MyDocumentType.from_publishing_api(payload)
        attachment = document.find_attachment(attachment_content_id)

        expect(attachment).to eq(document.attachments[0])
      end
    end
  end
end
