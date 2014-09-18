require "fast_spec_helper"
require "formatters/specialist_document_publication_alert_formatter"

RSpec.describe SpecialistDocumentPublicationAlertFormatter do

  let(:document) {
    double(:document,
      title: "Some title",
      slug: "some-prefix/some-permalink",
    )
  }
  subject(:formatter) { SpecialistDocumentPublicationAlertFormatter.new(document) }

  it "has an identifier with url of the finder for that format" do
    expect(formatter.identifier).to include("#{Plek.current.find("finder-frontend")}/some-prefix")
  end

  it "has a subject containing the document title" do
    expect(formatter.subject).to include("Some title")
  end

  it "has a body containing the document title and a link to the document" do
    expect(formatter.body).to include("Some title")
    expect(formatter.body).to include("#{Plek.current.find("specialist-frontend")}/some-prefix/some-permalink")
  end
end
