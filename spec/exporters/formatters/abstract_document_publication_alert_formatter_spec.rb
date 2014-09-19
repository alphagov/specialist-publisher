require "fast_spec_helper"
require "formatters/abstract_document_publication_alert_formatter"

RSpec.describe AbstractDocumentPublicationAlertFormatter do

  let(:url_maker) {
    double(:url_maker,
      published_specialist_document_path: "http://www.example.com"
    )
  }
  let(:document) {
    double(:document,
      title: "Some title",
      slug: "some-prefix/some-permalink",
      summary: "some summary",
      version_number: 1
    )
  }
  subject(:formatter) {
    Class.new(AbstractDocumentPublicationAlertFormatter) {
      private
      def human_document_type
        "Specialist Documents"
      end

      def document_noun
        "document"
      end
    }.new(
      url_maker: url_maker,
      document: document,
    )
  }

  it "has an identifier with url of the finder for that format" do
    expect(formatter.identifier).to include("#{Plek.current.find("finder-frontend")}/some-prefix")
  end

  it "has a subject containing the document title" do
    expect(formatter.subject).to include("Specialist Documents")
    expect(formatter.subject).to include("Some title")
  end

  it "has a body containing the document title, url, and summary" do
    expect(formatter.body).to include("Some title")
    expect(formatter.body).to include("http://www.example.com")
    expect(formatter.body).to include("some summary")
    expect(formatter.body).to include("published")
  end

  it "includes 'updated' in the body if its not the first document version" do
    allow(document).to receive(:version_number).and_return(2)
    expect(formatter.body).to include("updated")
  end
end
