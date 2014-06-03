require "fast_spec_helper"

require "manual_link_list_body_renderer"

RSpec.describe ManualLinkListBodyRenderer do
  subject(:rendered_manual) {
    ManualLinkListBodyRenderer.new(manual)
  }

  let(:manual) { double(:manual, documents: documents) }
  let(:documents) { [document] }

  let(:document) {
    double(
      :document,
      title: "Document Title",
      slug: "manuals/document-slug",
    )
  }

  let(:document_markdown_link) {
    "* [Document Title](/manuals/document-slug)\n"
  }

  describe "#body" do
    it "constructs a markdown list of links to each document" do
      expect(rendered_manual.body).to include(document_markdown_link)
    end
  end

end
