require "fast_spec_helper"

require "document_headers_depth_limiter"

describe DocumentHeadersDepthLimiter do

  subject(:header_limited_doc) {
    DocumentHeadersDepthLimiter.new(doc, depth: depth)
  }

  let(:doc) { double(:doc, serialized_headers: serialized_headers) }
  let(:depth) { 2 }

  let(:serialized_headers) {
    [
      text: "Level 1",
      headers: [
        {
          text: "Level 2",
          headers: [
            text: "Level 3",
            headers: [
              {
                text: "Level 4",
                headers: [],
              },
            ],
          ],
        },
      ],
    ]
  }

  let(:depth_limited_headers) {
    [
      text: "Level 1",
      headers: [
        {
          text: "Level 2",
          headers: [],
        }
      ],
    ]
  }

  it "is a true decorator" do
    args = [Object.new]
    expect(doc).to receive(:arbitrary_message).with(*args)

    header_limited_doc.arbitrary_message(*args)
  end

  describe "#headers" do
    before do
      allow(doc).to receive(:headers).and_return(headers)
    end

    let(:headers) { double(:headers) }

    it "does not interfere with the header objects" do
      expect(header_limited_doc.headers).to eq(headers)
    end
  end

  describe "#attributes" do
    let(:doc_attributes) { { foo: double(:bar) } }

    before do
      allow(doc).to receive(:attributes).and_return(doc_attributes)
    end

    it "adds serialized headers into the attributes hash" do
      expect(
        header_limited_doc.attributes.fetch(:headers)
      ).to eq(depth_limited_headers)
    end

    it "does not overwrite any other attribute keys from the document" do
      expect(
        header_limited_doc.attributes
      ).to match(hash_including(doc_attributes))
    end
  end

  describe "#serialized_headers" do
    it "limits nested headers to the specified depth" do
      expect(
        header_limited_doc.serialized_headers
      ).to eq(depth_limited_headers)
    end

    it "does not mutate the original data structure" do
      header_limited_doc.serialized_headers

      expect(
        serialized_headers
          .fetch(0)
          .fetch(:headers)
          .fetch(0)
          .fetch(:headers)
          .fetch(0)
          .fetch(:headers)
          .fetch(0)
          .fetch(:text)
      ).to eq("Level 4")
    end
  end
end
