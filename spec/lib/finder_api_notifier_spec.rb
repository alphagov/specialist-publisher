require "fast_spec_helper"
require "finder_api_notifier"

describe FinderAPINotifier do
  describe "#call(document)" do
    subject(:notifier) { FinderAPINotifier.new(api_client, markdown_attachment_renderer) }

    let(:api_client) { double(:finder_api, notify_of_publication: nil) }
    let(:markdown_attachment_renderer) { double(:markdown_attachment_renderer) }
    let(:document) { double(:document) }
    let(:markdown_document_slug) { "cma-cases/a-cma-case-document" }
    let(:markdown_document_attributes) {
      {
        good_value: "I am good",
        bad_value: "",
      }
    }

    let(:filtered_attributes) {
      {
        good_value: "I am good",
        bad_value: nil,
      }
    }

    let(:markdown_document) {
      double(
        :markdown_document,
        attributes: markdown_document_attributes,
        slug: markdown_document_slug,
      )
    }

    before do
      allow(markdown_attachment_renderer).to receive(:call).and_return(markdown_document)
    end

    it "renders the document into plain markdown" do
      notifier.call(document)

      expect(markdown_attachment_renderer).to have_received(:call).with(document)
    end

    it "sends filtered document attributes to the Finder API" do
      notifier.call(document)

      expect(api_client).to have_received(:notify_of_publication).with(
        markdown_document_slug,
        filtered_attributes,
      )
    end
  end
end
