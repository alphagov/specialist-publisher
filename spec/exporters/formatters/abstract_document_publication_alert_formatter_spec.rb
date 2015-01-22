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
      change_note: change_note,
      version_number: version_number,
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

  context "a new document" do
    let(:change_note) { "First published." }
    let(:version_number) { 1 }

    it "has a name which corresponds to the topic name" do
      expect(formatter.name).to eql("Specialist Documents")
    end

    it "has tags which correspond to the email filter tags for that document type (format)" do
      expect(formatter.tags[:format]).to eql(["document"])
      expect(formatter.tags[:metadata_attribute]).to eql([metadata_attribute])
      expect(formatter.tags[:array_metadata_attribute]).to eql(array_metadata_attribute)
    end

    it "has a subject containing the document title" do
      expect(formatter.subject).to eq("Some title")
    end

    it "has a body containing the document title, url, and summary" do
      expect(formatter.body).to include("Some title")
      expect(formatter.body).to include("http://www.example.com")
      expect(formatter.body).to include("some summary")
      expect(formatter.body).to include("published")
    end

    it "doesn't include the change note in the body" do
      expect(formatter.body).to_not include("First published")
    end
  end

  context "an updated document" do
    let(:change_note) { "This is the change note" }
    let(:version_number) { 2 }

    it "includes 'updated' in the body" do
      expect(formatter.body).to include("updated")
    end

    it "includes the change note in the body" do
      expect(formatter.body).to include("This is the change note")
    end
  end
end
