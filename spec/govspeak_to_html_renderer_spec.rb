require "fast_spec_helper"

require "govspeak_to_html_renderer"

describe GovspeakToHTMLRenderer do
  let(:renderer) {
    GovspeakToHTMLRenderer.new(
      govspeak_html_converter,
      document,
    )
  }

  let(:document) {
    double(:document,
      body: document_body,
      attributes: document_attributes
    )
  }

  let(:document_attributes) {
    {
      a_field_name: "a value",
    }
  }

  let(:govspeak_html_converter) {
    double(:govspeak_converter, call: converted_body)
  }

  let(:document_body) { double(:document_body) }
  let(:converted_body) { double(:converted_body) }

  it "is a true decorator" do
    expect(document).to receive(:any_arbitrary_message)

    document.any_arbitrary_message
  end

  describe "#body" do
    it "converts the document body" do
      renderer.body

      expect(govspeak_html_converter).to have_received(:call).with(document_body)
    end

    it "returns the converted body" do
      expect(renderer.body).to eq(converted_body)
    end
  end

  describe "#attributes" do
    it "merges the converted body into the document attributes" do
      expect(renderer.attributes).to include(
        body: converted_body,
      )

      expect(renderer.attributes).to include(document_attributes)
    end
  end
end
