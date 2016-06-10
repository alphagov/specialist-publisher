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
            content: "This is the body of an example document",
          },
          {
            content_type: "text/html",
            content: "<p>This is the body of an example document</p>\n",
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
      publishing_api_has_item(payload)
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
        "indexable_content" => "This is the body of an example document",
        "link" => "/my-document-types/example-document",
        "public_timestamp" => "2015-11-16T11:53:30+00:00",
        "first_published_at" => "2015-11-15T00:00:00+00:00",
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

    context "document has never been published" do
      let(:unpublished_document) { MyDocumentType.from_publishing_api(payload.except("first_published_at")) }

      it 'sends first_published_at to Rummager' do
        unpublished_document.publish!
        assert_rummager_posted_item(
          "title" => "Example document",
          "description" => "This is a summary",
          "indexable_content" => "This is the body of an example document",
          "link" => "/my-document-types/example-document",
          "public_timestamp" => "2015-11-16T11:53:30+00:00",
          "first_published_at" => "2015-11-15T00:00:00+00:00",
          "field1" => "2015-12-01",
          "field2" => "open",
        )
      end
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
      publishing_api_has_item(payload)
      stub_request(:post, %r{#{Plek.new.find('search')}/documents}).to_return(status: 503)
      expect(document.publish!).to eq(false)
    end
  end

  describe "#withdraw" do
    before do
      publishing_api_has_item(payload)
      document = MyDocumentType.find(payload["content_id"])
      stub_publishing_api_unpublish(document.content_id, body: { type: 'gone' })
    end

    it "sends correct payload to publishing api" do
      expect(document.withdraw).to eq(true)

      assert_publishing_api_unpublish(document.content_id)
    end

    context "unsuccessful #unpublish" do
      it "notifies Airbrake and returns false if publishing-api does not return status 200" do
        expect(Airbrake).to receive(:notify)
        stub_publishing_api_unpublish(document.content_id, { body: { type: 'gone' } }, status: 409)
        expect(document.withdraw).to eq(false)
      end
    end
  end

  describe "#save" do
    before do
      publishing_api_has_item(payload)
      Timecop.freeze(Time.parse("2015-12-18 10:12:26 UTC"))
    end

    it "saves document" do
      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links

      c = MyDocumentType.find(payload["content_id"])
      expect(c.save).to eq(true)

      expected_payload = saved_for_the_first_time(write_payload(payload.deep_stringify_keys))
      assert_publishing_api_put_content(c.content_id, expected_payload)
    end

    it "returns false without making any Publishing API calls if the document is invalid" do
      stub = stub_any_publishing_api_call

      document.title = nil # this is an invalid title
      expect(document).to_not be_valid

      expect(document.save).to be_falsey
      expect(stub).to_not have_been_requested
    end

    it "returns false if the Publishing API calls fail" do
      publishing_api_isnt_available
      expect(document.save).to be_falsey
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

  describe "attachment methods" do
    let(:attachment) { Attachment.new }

    describe "#attachments=" do
      it "creates an AttachmentCollection with the given attachments" do
        subject.attachments = [attachment]

        expect(subject.attachments).to be_kind_of(AttachmentCollection)
        expect(subject.attachments.first).to eq(attachment)
      end
    end

    describe "#attachments" do
      it "returns an empty AttachmentCollection if none is set" do
        expect(subject.attachments).to be_kind_of(AttachmentCollection)
        expect(subject.attachments.count).to eq(0)
      end
    end

    describe "#upload_attachment" do
      before do
        subject.attachments = [attachment]
      end

      it "saves itself on successful attachment upload" do
        expect(subject.attachments).to receive(:upload).and_return(true)
        expect(subject).to receive(:save)
        subject.upload_attachment(attachment)
      end

      it "returns false on failed attachment upload" do
        expect(subject.attachments).to receive(:upload).and_return(false)

        expect(subject.upload_attachment(attachment)).to eq(false)
      end
    end
  end
end
