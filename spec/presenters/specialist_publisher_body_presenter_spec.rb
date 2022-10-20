require "spec_helper"

RSpec.describe SpecialistPublisherBodyPresenter do
  subject { described_class }
  let(:document) do
    instance_double(
      Document,
      body: { content: },
      attachments:,
    )
  end
  let(:attachment) do
    instance_double(
      Attachment,
      content_id: "12345",
      url: "https://domain/fluff.pdf",
      content_type: "application/pdf",
    )
  end
  let(:image) do
    instance_double(
      Attachment,
      content_id: "6789",
      url: "https://domain/fluff.jpg",
      content_type: "application/jpg",
    )
  end

  describe ".present" do
    let(:result) { subject.present(document)[:content] }

    context "body includes inline attachment" do
      context "matching attachment doesn't exist" do
        let(:attachments) { [] }
        let(:content) { "[embed:attachments:inline:fluff.pdf]" }

        it "presents InlineAttachment syntax" do
          expect(result).to eq "[InlineAttachment:fluff.pdf]"
        end
      end

      context "matching attachment exists" do
        let(:content) { "[embed:attachments:inline:12345]" }
        let(:attachments) { [attachment] }

        it "presents InlineAttachment syntax" do
          expect(result).to eq "[InlineAttachment:fluff.pdf]"
        end
      end
    end

    context "body includes image" do
      context "matching attachment doesn't exist" do
        let(:attachments) { [] }
        let(:content) { "[embed:attachments:image:fluff.jpg]" }

        it "presents InlineAttachment syntax" do
          expect(result).to eq "![InlineAttachment:fluff.jpg]"
        end
      end

      context "matching attachment exists" do
        let(:content) { "[embed:attachments:image:6789]" }
        let(:attachments) { [image] }

        it "presents InlineAttachment syntax" do
          expect(result).to eq "![InlineAttachment:fluff.jpg]"
        end
      end
    end
  end
end
