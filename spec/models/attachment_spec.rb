require 'spec_helper'

RSpec.describe Attachment do
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
end
