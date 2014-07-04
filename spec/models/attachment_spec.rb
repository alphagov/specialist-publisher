require "fast_spec_helper"
require "attachment"

describe Attachment do
  subject(:attachment) do
    Attachment.new(
      title: "Supporting attachment",
      filename: "document.pdf",
    )
  end

  it "generates a snippet" do
    expect(attachment.snippet).to eq("[InlineAttachment:document.pdf]")
  end
end
