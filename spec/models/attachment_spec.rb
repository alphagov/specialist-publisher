require 'spec_helper'
require 'gds_api/test_helpers/asset_manager'
RSpec.describe Attachment do
  include GdsApi::TestHelpers::AssetManager

  describe ".all_from_publishing_api" do
    context "when the payload has attachments in details" do
      let(:attachment_payload) { FactoryGirl.create(:attachment_payload) }

      let(:payload) do
        { "details" => { "attachments" => [attachment_payload] } }
      end

      it "returns an array of attachments" do
        attachments = described_class.all_from_publishing_api(payload)

        expect(attachments.size).to eq(1)
        attachment = attachments.first

        expect(attachment.title).to eq(attachment_payload["title"])
        expect(attachment.file).to eq(attachment_payload["file"])
        expect(attachment.content_type).to eq(attachment_payload["content_type"])
        expect(attachment.url).to eq(attachment_payload["url"])
        expect(attachment.content_id).to eq(attachment_payload["content_id"])
        expect(attachment.created_at).to eq(attachment_payload["created_at"])
        expect(attachment.updated_at).to eq(attachment_payload["updated_at"])
      end

      context "when a content id is not provided" do
        let(:attachment_payload) {
          FactoryGirl.create(:attachment_payload, content_id: nil)
        }

        it "generates a content id" do
          allow(SecureRandom).to receive(:uuid).and_return("some-content-id")

          attachments = described_class.all_from_publishing_api(payload)
          attachment = attachments.first

          expect(attachment.content_id).to eq("some-content-id")
        end
      end
    end

    context "when the payload does not have attachments" do
      let(:payload) { {} }

      it "returns an empty array" do
        attachments = described_class.all_from_publishing_api(payload)
        expect(attachments).to eq([])
      end
    end
  end

  describe "#new" do
    let(:attachment) {
      Attachment.new(
        title: 'test attachment',
        file: ActionDispatch::Http::UploadedFile.new(
          tempfile: "spec/support/images/cma_case_image.jpg",
          filename: File.basename("spec/support/images/cma_case_image.jpg"),
          type: "image/jpeg"
        ),
      )
    }

    it "should set content_id and file attributes with data from attachments new form" do
      expect(attachment.content_id).to be_truthy
      expect(attachment.file.content_type).to eq("image/jpeg")
      expect(attachment.file.tempfile).to eq("spec/support/images/cma_case_image.jpg")
      expect(attachment.created_at).to be(nil)
      expect(attachment.updated_at).to be(nil)
      expect(attachment.url).to be(nil)
      expect(attachment.content_type).to be(nil)
    end

    it "should set content_id, title, url, created_at and updated_at with data from publishing-api" do
      content_id = SecureRandom.uuid
      attachment = Attachment.new(
        title: 'test attachment',
        content_id: content_id,
        url: "/path/to/file/in/asset/manager",
        content_type: 'image/jpg',
        created_at: "2015-12-03T16:59:13+00:00",
        updated_at: "2015-12-03T16:59:13+00:00",
      )
      expect(attachment.content_id).to eq(content_id)
      expect(attachment.url).to eq("/path/to/file/in/asset/manager")
      expect(attachment.content_type).to eq("image/jpg")
      expect(attachment.created_at).to eq("2015-12-03T16:59:13+00:00")
      expect(attachment.updated_at).to eq("2015-12-03T16:59:13+00:00")
      expect(attachment.file).to be(nil)
    end
  end

  describe "#update_attributes" do
    let(:content_id) { SecureRandom.uuid }

    let(:attachment) {
      Attachment.new(
        title: 'test attachment',
        content_id: content_id,
        url: "/path/to/file/in/asset/manager",
        content_type: 'image/jpg',
        created_at: "2015-12-03T16:59:13+00:00",
        updated_at: "2015-12-03T16:59:13+00:00",
      )
    }

    let(:http_file_upload) {
      ActionDispatch::Http::UploadedFile.new(
        tempfile: "spec/support/images/updated_cma_case_image.jpg",
        filename: File.basename("spec/support/images/updated_cma_case_image.jpg"),
        type: "image/jpeg"
      )
    }

    it "should update the title, file and has_changed attributes" do
      attachment.update_attributes(file: http_file_upload, title: "updated attachment title")

      expect(attachment.file).to eq(http_file_upload)
      expect(attachment.title).to eq("updated attachment title")
    end
  end

  describe "#upload" do
    let(:url) { '/uploaded/document.jpg' }
    let(:attachment) {
      Attachment.new(
        title: 'test attachment',
        file: ActionDispatch::Http::UploadedFile.new(
          tempfile: Tempfile.new("cma_case_image.jpg"),
          filename: File.basename("spec/support/images/cma_case_image.jpg"),
          type: "image/jpeg"
        ),
      )
    }

    it "returns true on successful upload and sets the url" do
      asset_manager_receives_an_asset(url)

      expect(attachment.upload).to eq(true)
      expect(attachment.url).to eq(url)
    end

    it "returns false on failed upload and does not set the url" do
      asset_manager_upload_failure

      expect(attachment.upload).to eq(false)
      expect(attachment.url).to be_nil
    end
  end
end
