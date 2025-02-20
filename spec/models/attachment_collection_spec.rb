require "spec_helper"

RSpec.describe AttachmentCollection do
  let(:attachment_jpeg) { Attachment.new(title: "jolly jpeg") }
  let(:attachment_gif) { Attachment.new(title: "great gif") }
  let(:missing_attachment) { Attachment.new(title: "cool csv") }
  let(:attachments) { described_class.new([attachment_jpeg, attachment_gif]) }
  let(:finder_schema) do
    schema = FinderSchema.new
    schema.assign_attributes({
      base_path: "/my-document-types",
      target_stack: "live",
      filter: {
        "format" => "my_format",
      },
      content_id: @finder_content_id,
    })
    schema
  end

  before do
    allow(FinderSchema).to receive(:load_from_schema).and_return(finder_schema)
  end

  describe "#find" do
    it "returns the correct attachment" do
      expect(attachments.find(attachment_gif.content_id)).to eq(attachment_gif)
    end

    it "returns nil for an non-existent attachment" do
      expect(attachments.find(missing_attachment.content_id)).to be_nil
    end
  end

  describe "#build" do
    it "adds a new attachment to entries" do
      expect { attachments.build(title: "new and shiny") }.to change { attachments.count }.from(2).to(3)
      expect(attachments.to_a.last.title).to eq("new and shiny")
    end
  end

  describe "#upload" do
    it "triggers upload if the current attachment is in the array" do
      expect(attachment_jpeg).to receive(:upload)
      attachments.upload(attachment_jpeg)
    end

    it "does not call upload if attachment not found" do
      expect(missing_attachment).to_not receive(:upload)
      attachments.upload(missing_attachment)
    end
  end

  describe "#has_attachment?" do
    it "returns true for a found attachment" do
      expect(attachments.has_attachment?(attachment_jpeg)).to eq(true)
    end

    it "returns false for a non-existent attachment" do
      expect(attachments.has_attachment?(missing_attachment)).to eq(false)
    end
  end

  describe "#each" do
    it "iterates over its attachments" do
      titles = []

      attachments.each { |a| titles << a.title }

      expect(titles).to eq([attachment_jpeg.title, attachment_gif.title])
    end
  end
end
