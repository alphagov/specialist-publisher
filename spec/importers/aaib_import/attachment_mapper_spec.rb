require "fast_spec_helper"
require "aaib_import/attachment_mapper"

RSpec.describe AaibImport::AttachmentMapper do
  subject(:mapper) do
    AaibImport::AttachmentMapper.new(aaib_import_mapper,
      repo,
      "spec/fixtures/import",
    )
  end

  let(:raw_body) {
    "Lorem ipsum dolor sit amet [ASSET_TAG](#ASSET0)"
  }
  let(:attachment_filename) { "2_1981 G_BAOZ.pdf" }
  let(:govspeak_attachment_string) { "[InlineAttachment: #{attachment_filename}]" }
  let(:expected_title) { "2-1981 G-BAOZ.pdf" }
  let(:expected_body) { "Lorem ipsum dolor sit amet #{govspeak_attachment_string}" }
  let(:attachment) { double(:attachment, snippet: govspeak_attachment_string) }

  let(:document) { double(:document, valid?: true, attributes: {}, body: raw_body, add_attachment: attachment) }
  let(:aaib_import_mapper) { double(:aaib_import_mapper, call: document) }
  let(:repo) { double(:repository, store: true) }

  let(:raw_data) {
    {
      "original_url" => "http://www.aaib.gov.uk/publications/formal_reports/2_1981_g_baoz.cfm",
      "assets" => [
        {
          "filename" => "downloads/162/2-1981 G-BAOZ.pdf",
          "content_type" => "application/pdf",
          "original_url" => "http://www.aaib.gov.uk/cms_resources/2-1981 G-BAOZ.pdf",
          "original_filename" => attachment_filename,
          "title" => attachment_filename,
          "assetid" => 0,
        }
      ],
      "body" => raw_body,
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
