require "fast_spec_helper"
require "formatters/abstract_document_publication_alert_formatter"

RSpec.describe AbstractDocumentPublicationAlertFormatter do

  let(:url_maker) {
    double(:url_maker,
      published_specialist_document_path: "http://www.example.com"
    )
  }
  let(:metadata_attribute) { double(:metadata_attribute) }
  let(:array_metadata_attribute) { [double(:metadata_attribute_in_array)] }
  let(:document) {
    double(:document,
      document_type: "document",
      title: "Some title",
      slug: "some-prefix/some-permalink",
      summary: "some summary",
      version_number: 1,
      extra_fields: {
        metadata_attribute: metadata_attribute,
        array_metadata_attribute: array_metadata_attribute
      },
    )
  }
  subject(:formatter) {
    Class.new(AbstractDocumentPublicationAlertFormatter) {

      def name
        "Specialist Documents"
      end

    private
      def document_noun
        "document"
      end
    }.new(
      url_maker: url_maker,
      document: document,
    )
  }

  it "has a name which corresponds to the topic name" do
    expect(formatter.name).to eql("Specialist Documents")
  end

  it "has tags which correspond to the email filter tags for that document type (format)" do
    expect(formatter.tags[:format]).to eql(["document"])
    expect(formatter.tags[:metadata_attribute]).to eql([metadata_attribute])
    expect(formatter.tags[:array_metadata_attribute]).to eql(array_metadata_attribute)
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
