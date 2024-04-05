require "spec_helper"
require "gds_api/test_helpers/asset_manager"
RSpec.describe Attachment do
  include GdsApi::TestHelpers::AssetManager

  describe ".all_from_publishing_api" do
    context "when the payload has attachments in details" do
      let(:attachment_payload) { FactoryBot.create(:attachment_payload) }

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
        let(:attachment_payload) do
          FactoryBot.create(:attachment_payload, content_id: nil)
        end

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

  describe "#new without title" do
    let(:attachment) do
      Attachment.new(
        title: "",
        file: ActionDispatch::Http::UploadedFile.new(
          tempfile: "spec/support/images/cma_case_image.jpg",
          filename: File.basename("spec/support/images/cma_case_image.jpg"),
          original_filename: "cma_case_image.jpg",
          type: "image/jpeg",
        ),
      )
    end

    it "should set content_id and file attributes with data from attachments new form" do
      expect(attachment.content_id).to be_truthy
      expect(attachment.file.content_type).to eq("image/jpeg")
      expect(attachment.file.tempfile).to eq("spec/support/images/cma_case_image.jpg")
      expect(attachment.title).to eq("cma_case_image")
      expect(attachment.created_at).to be(nil)
      expect(attachment.updated_at).to be(nil)
      expect(attachment.url).to be(nil)
      expect(attachment.content_type).to be(nil)
    end

    it "should set content_id, title, url, created_at and updated_at with data from publishing-api" do
      content_id = SecureRandom.uuid
      attachment = Attachment.new(
        title: "",
        content_id:,
        url: "/path/to/file/in/asset/manager/cma_case_image.jpg",
        content_type: "image/jpg",
        created_at: "2015-12-03T16:59:13+00:00",
        updated_at: "2015-12-03T16:59:13+00:00",
      )
      expect(attachment.content_id).to eq(content_id)
      expect(attachment.title).to eq("cma_case_image")
      expect(attachment.url).to eq("/path/to/file/in/asset/manager/cma_case_image.jpg")
      expect(attachment.content_type).to eq("image/jpg")
      expect(attachment.created_at).to eq("2015-12-03T16:59:13+00:00")
      expect(attachment.updated_at).to eq("2015-12-03T16:59:13+00:00")
      expect(attachment.file).to be(nil)
    end
  end

  describe "#new with title" do
    let(:attachment) do
      Attachment.new(
        title: "new attachment",
        file: ActionDispatch::Http::UploadedFile.new(
          tempfile: "spec/support/images/cma_case_image.jpg",
          filename: File.basename("spec/support/images/cma_case_image.jpg"),
          original_filename: "cma_case_image.jpg",
          type: "image/jpeg",
        ),
      )
    end

    it "should set content_id and file attributes with data from attachments new form" do
      expect(attachment.content_id).to be_truthy
      expect(attachment.file.content_type).to eq("image/jpeg")
      expect(attachment.file.tempfile).to eq("spec/support/images/cma_case_image.jpg")
      expect(attachment.title).to eq("new attachment")
      expect(attachment.created_at).to be(nil)
      expect(attachment.updated_at).to be(nil)
      expect(attachment.url).to be(nil)
      expect(attachment.content_type).to be(nil)
    end

    it "should set content_id, title, url, created_at and updated_at with data from publishing-api" do
      content_id = SecureRandom.uuid
      attachment = Attachment.new(
        title: "new attachment",
        content_id:,
        url: "/path/to/file/in/asset/manager/cma_case_image.jpg",
        content_type: "image/jpg",
        created_at: "2015-12-03T16:59:13+00:00",
        updated_at: "2015-12-03T16:59:13+00:00",
      )
      expect(attachment.content_id).to eq(content_id)
      expect(attachment.title).to eq("new attachment")
      expect(attachment.url).to eq("/path/to/file/in/asset/manager/cma_case_image.jpg")
      expect(attachment.content_type).to eq("image/jpg")
      expect(attachment.created_at).to eq("2015-12-03T16:59:13+00:00")
      expect(attachment.updated_at).to eq("2015-12-03T16:59:13+00:00")
      expect(attachment.file).to be(nil)
    end
  end

  describe ".valid_filetype?" do
    it "should check that a file extension has been white listed" do
      tempfile = Tempfile.new(["foobar", ".jpeg"])
      extension = File.extname(tempfile)
      allow_any_instance_of(File).to receive(:tempfile).and_return(extension)
      expect(EXTENSION_WHITE_LIST.include?(File.extname(tempfile))).to eq(false)
    end
  end

  describe "#update_properties" do
    let(:content_id) { SecureRandom.uuid }

    let(:attachment) do
      Attachment.new(
        title: "test attachment",
        content_id:,
        url: "/path/to/file/in/asset/manager",
        content_type: "image/jpg",
        created_at: "2015-12-03T16:59:13+00:00",
        updated_at: "2015-12-03T16:59:13+00:00",
      )
    end

    let(:http_file_upload) do
      ActionDispatch::Http::UploadedFile.new(
        tempfile: "spec/support/images/updated_cma_case_image.jpg",
        filename: File.basename("spec/support/images/updated_cma_case_image.jpg"),
        type: "image/jpeg",
      )
    end

    it "should update the title, file and has_changed attributes" do
      attachment.update_properties(file: http_file_upload, title: "updated attachment title")

      expect(attachment.file).to eq(http_file_upload)
      expect(attachment.title).to eq("updated attachment title")
    end
  end

  describe "#upload" do
    let(:url) { "/uploaded/document.jpg" }
    let(:attachment) do
      Attachment.new(
        title: "test attachment",
        file: ActionDispatch::Http::UploadedFile.new(
          tempfile: Tempfile.new("cma_case_image.jpg"),
          filename: File.basename("spec/support/images/cma_case_image.jpg"),
          type: "image/jpeg",
        ),
      )
    end

    it "returns true on successful upload and sets the url" do
      stub_asset_manager_receives_an_asset(url)

      expect(attachment.upload).to eq(true)
      expect(attachment.url).to eq(url)
    end

    it "returns false on failed upload and does not set the url" do
      stub_asset_manager_upload_failure

      expect(attachment.upload).to eq(false)
      expect(attachment.url).to be_nil
    end
  end

  describe "#snippet" do
    context "when the attachment has a url" do
      let(:attachment) { Attachment.new(url: "http://example.com/a/b/c/foo.png") }

      it "returns a snippet containing the suffix of the url" do
        expect(attachment.snippet).to eq("[InlineAttachment:foo.png]")
      end
    end

    context "when the attachment does not have a url" do
      let(:attachment) { Attachment.new(content_id: "some-content-id") }

      it "returns a snippet containing the content_id" do
        expect(attachment.snippet).to eq("[InlineAttachment:some-content-id]")
      end
    end
  end

  describe "#destroy" do
    let(:asset_id) { "some-asset-id" }
    let(:url) { "/#{asset_id}/document.pdf" }
    let(:attachment) do
      Attachment.new(
        title: "test attachment",
        url:,
      )
    end

    context "when the request to delete the attachment asset from AssetManager succeeds" do
      it "returns a truthy value" do
        stub_asset_manager_delete_asset(asset_id)
        expect(attachment.destroy).to be_truthy
      end
    end

    context "when the attachment does not exist in Asset Manager" do
      it "returns a truthy value" do
        stub_asset_manager_delete_asset_missing(asset_id)
        expect(attachment.destroy).to be_truthy
      end
    end

    context "when the request to delete the attachment asset in Asset Manager fails for other reasons" do
      it "returns false" do
        stub_asset_manager_delete_asset_failure(asset_id)
        expect(attachment.destroy).to be false
      end
    end
  end
end
