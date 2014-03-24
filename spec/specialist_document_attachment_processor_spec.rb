require "support/fast_spec_helper"

require "specialist_document_attachment_processor"

describe SpecialistDocumentAttachmentProcessor do
  subject(:renderer) { SpecialistDocumentAttachmentProcessor.new(doc) }

  let(:unprocessed_body) {
%{
# Hi

this is my attachment [InlineAttachment:rofl.gif] 28 Feb 2014
}
  }

  let(:processed_body) {
%{
# Hi

this is my attachment [#{title}](#{file_url}) 28 Feb 2014
}
  }

  let(:doc) { double(:doc, body: unprocessed_body, attachments: attachments) }

  let(:attachments) { [lol, rofl] }

  let(:title) { "My attachment ROFL" }
  let(:file_url) { "http://example.com/rofl.gif" }

  let(:rofl) {
    double(:attachment,
      title: title,
      filename: "rofl.gif",
      file_url: file_url,
      snippet: "[InlineAttachment:rofl.gif]",
    )
  }

  let(:lol) {
    double(:attachment,
      title: "My attachment LOL",
      filename: "lol.gif",
      file_url: "http://example.com/LOL",
      snippet: "[InlineAttachment:lol.gif]",
    )
  }

  describe "#body" do
    it "replaces inline attachment tags with link" do
      expect(renderer.body).to eq(processed_body)
    end
  end

end
