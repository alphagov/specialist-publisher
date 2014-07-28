require "fast_spec_helper"
require "dfid_import/attachment_mapper"

RSpec.describe DfidImport::AttachmentMapper do
  subject(:mapper) do
    DfidImport::AttachmentMapper.new(dfid_import_mapper,
      repo,
      logger,
      "spec/fixtures/dfid_import",
    )
  end

  let(:logger) { double(:logger, success: true) }

  let(:raw_body) {
    "Lorem ipsum dolor sit amet [InlineAttachment:1]"
  }

  let(:attachment_filename) { "Attached-document.pdf" }
  let(:govspeak_attachment_string) { "[InlineAttachment: #{attachment_filename}]" }
  let(:expected_body) { "Lorem ipsum dolor sit amet #{govspeak_attachment_string}" }
  let(:expected_title) { "Attachment title" }
  let(:attachment) { double(:attachment, snippet: govspeak_attachment_string) }
  let(:document) { double(:document, valid?: true, attributes: {}, body: raw_body, add_attachment: attachment) }
  let(:dfid_import_mapper) { double(:dfid_import_mapper, call: document) }
  let(:repo) { double(:repository, store: true) }

  let(:raw_data) {
    {
      "title" =>  expected_title,
      "summary" => "International development report summary",
      "body" => raw_body,
      "import_source" => "100100",
      "attachments" => [
        {
          "title" => expected_title,
          "filename" => attachment_filename,
          "identifier" => 1
        }
      ]
    }
  }

  before do
    allow(document).to receive(:update)
  end

  it "replaces attachment links within the body text with attachments snippet" do
    expect(document).to receive(:update).with(body: expected_body)
    mapper.call(raw_data)
  end

  it "attaches assets" do
    expect(document).to receive(:add_attachment).with({
      title: expected_title,
      filename: attachment_filename,
      file: instance_of(File),
    }).and_return(attachment)
    mapper.call(raw_data)
  end
end
