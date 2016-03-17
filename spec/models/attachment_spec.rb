require 'spec_helper'

describe Attachment do

  describe "attachment object with data from attachment new form" do
    let(:attachment) {
      Attachment.new({
       file: ActionDispatch::Http::UploadedFile.new(tempfile: "spec/support/images/cma_case_image.jpg", filename: File.basename("spec/support/images/cma_case_image.jpg"),type: "image/jpeg"),
       title: 'test attachment'
      })
    }

    it "should have content_id and file attributes set" do
      expect(attachment.content_id).to be_truthy
      expect(attachment.file.content_type).to eq("image/jpeg")
      expect(attachment.file.tempfile).to eq("spec/support/images/cma_case_image.jpg")
      expect(attachment.created_at).to be(nil)
      expect(attachment.updated_at).to be(nil)
      expect(attachment.url).to be(nil)
      expect(attachment.content_type).to be(nil)
    end
  end

  describe "attachment object with data form publishing-api" do
    let(:content_id) { SecureRandom.uuid }

    let(:attachment) {
      Attachment.new({
        title: 'test attachment',
        content_id: content_id,
        url: "/path/to/file/in/asset/manager",
        content_type: 'image/jpg',
        created_at: "2015-12-03T16:59:13+00:00",
        updated_at: "2015-12-03T16:59:13+00:00"
      })
    }

    it "should have content_id, title, url, created_at and updated_at set" do
      expect(attachment.content_id).to eq(content_id)
      expect(attachment.url).to eq("/path/to/file/in/asset/manager")
      expect(attachment.content_type).to eq("image/jpg")
      expect(attachment.created_at).to eq("2015-12-03T16:59:13+00:00")
      expect(attachment.updated_at).to eq("2015-12-03T16:59:13+00:00")
      expect(attachment.file).to be(nil)
    end
  end
end

