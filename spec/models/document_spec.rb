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

  let(:payload_attributes) {
    {
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
      }
    }
  }
  let(:payload) { FactoryGirl.create(:document, payload_attributes) }
  let(:document) { MyDocumentType.from_publishing_api(payload) }

  before do
    allow_any_instance_of(FinderSchema).to receive(:load_schema_for).with("my_document_types").
      and_return(finder_schema)
  end

  context "successful #publish!" do
    before do
      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links
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
      let(:unpublished_document) {
        MyDocumentType.from_publishing_api(
          FactoryGirl.create(:document,
            payload_attributes.merge(
              first_published_at: nil,
              publication_state: 'draft',
              change_history: [],
              content_id: document.content_id
            ))
        )
      }

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

      it 'saves a "First published" change note before asking the api to publish' do
        Timecop.freeze(Time.parse("2015-12-18 10:12:26 UTC")) do
          unpublished_document.publish!

          expected_change_history = [
            {
              "public_timestamp" => Time.current.iso8601,
              "note" => Document::FIRST_PUBLISHED_NOTE,
            },
          ]

          changed_json = {
            "update_type" => 'major',
            "details" => payload["details"].merge("change_history" => expected_change_history),
          }

          assert_publishing_api_put_content(unpublished_document.content_id, request_json_includes(changed_json))
        end
      end
    end

    shared_examples_for 'publishing changes to a document that has previously been published' do
      let(:published_document) {
        MyDocumentType.from_publishing_api(
          FactoryGirl.create(:document,
            :published,
            payload_attributes.merge(
              publication_state: publication_state,
              content_id: document.content_id
            ))
        )
      }

      it 'does not add a "First published" change note before asking the api to publish' do
        published_document.publish!

        assert_no_publishing_api_put_content(published_document.content_id)
      end
    end

    context "when document is in live state" do
      let(:publication_state) { 'live' }
      it_behaves_like 'publishing changes to a document that has previously been published'
    end

    context 'when document is in redrafted state' do
      let(:publication_state) { 'redrafted' }
      it_behaves_like 'publishing changes to a document that has previously been published'
    end

    context 'when document is in unpublished state' do
      let(:publication_state) { 'unpublished' }
      it_behaves_like 'publishing changes to a document that has previously been published'
    end

    context 'when document is in superseded state' do
      let(:publication_state) { 'superseded' }
      it_behaves_like 'publishing changes to a document that has previously been published'
    end
  end

  context "unsuccessful #publish!" do
    it "notifies Airbrake and returns false if publishing-api does not return status 200" do
      expect(Airbrake).to receive(:notify)
      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links
      stub_publishing_api_publish(document.content_id, {}, status: 503)
      stub_any_rummager_post_with_queueing_enabled
      expect(document.publish!).to eq(false)
    end

    it "notifies Airbrake and returns false if rummager does not return status 200" do
      expect(Airbrake).to receive(:notify)
      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links
      stub_publishing_api_publish(document.content_id, {})
      publishing_api_has_item(payload)
      stub_request(:post, %r{#{Plek.new.find('search')}/documents}).to_return(status: 503)
      expect(document.publish!).to eq(false)
    end
  end

  describe "#unpublish" do
    before do
      publishing_api_has_item(payload)
      document = MyDocumentType.find(payload["content_id"])
      stub_publishing_api_unpublish(document.content_id, body: { type: 'gone' })
    end

    it "sends correct payload to publishing api" do
      expect(document.unpublish).to eq(true)

      assert_publishing_api_unpublish(document.content_id)
    end

    context "unsuccessful #unpublish" do
      it "notifies Airbrake and returns false if publishing-api does not return status 200" do
        expect(Airbrake).to receive(:notify)
        stub_publishing_api_unpublish(document.content_id, { body: { type: 'gone' } }, status: 409)
        expect(document.unpublish).to eq(false)
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

      expected_payload = write_payload(payload.deep_stringify_keys)
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
    before do
      publishing_api_has_item(payload)
    end

    it "returns a document" do
      found_document = MyDocumentType.find(document.content_id)

      expect(found_document.base_path).to eq(payload["base_path"])
      expect(found_document.title).to     eq(payload["title"])
      expect(found_document.summary).to   eq(payload["description"])
      expect(found_document.body).to      eq(payload["details"]["body"][0]["content"])
      expect(found_document.field3).to    eq(payload["details"]["metadata"]["field3"])
    end

    describe "when called on the Document superclass" do
      it "returns an instance of the subclass with matching document_type" do
        found_document = Document.find(document.content_id)
        expect(found_document).to be_a(MyDocumentType)
      end
    end

    describe "when called on a class that mismatches the document_type" do
      it "raises a helpful error" do
        expect {
          CmaCase.find(document.content_id)
        }.to raise_error(/wrong type/)
      end
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

  context "change_history" do
    let(:note) { 'my change note' }
    let(:document) { MyDocumentType.new.tap { |document| document.change_note = note } }

    it 'add note when major change' do
      document.update_type = 'major'

      expect(document.change_history.last).to eq('public_timestamp' => Time.current.iso8601, 'note' => note)
    end

    it 'should not add note when minor change' do
      document.update_type = 'minor'

      expect(document.change_history).to be_empty
    end

    it 'should not add note when no update type' do
      document.update_type = ''

      expect(document.change_history).to be_empty
    end
  end

  context '#ever_been_published?' do
    let(:change_note_1) { { 'public_timestamp' => Time.current.iso8601, 'note' => 'Drafting' } }
    let(:change_note_2) { { 'public_timestamp' => Time.current.iso8601, 'note' => Document::FIRST_PUBLISHED_NOTE } }
    let(:change_note_3) { { 'public_timestamp' => Time.current.iso8601, 'note' => 'Making changes' } }
    subject { MyDocumentType.new }
    it "is true if there is a '#{Document::FIRST_PUBLISHED_NOTE}' entry in change_history" do
      subject.change_history = [change_note_1, change_note_2, change_note_3]
      expect(subject).to have_ever_been_published
    end

    it "is false if there is no '#{Document::FIRST_PUBLISHED_NOTE}' entry in change_history" do
      subject.change_history = [change_note_1, change_note_3]
      expect(subject).not_to have_ever_been_published
    end

    it "is false if the change_history is empty" do
      subject.change_history = []
      expect(subject).not_to have_ever_been_published
    end
  end
end
