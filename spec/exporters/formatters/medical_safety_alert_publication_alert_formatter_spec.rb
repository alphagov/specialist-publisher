require "fast_spec_helper"
require "formatters/abstract_document_publication_alert_formatter"

RSpec.describe MedicalSafetyAlertPublicationAlertFormatter do
  let(:url_maker) {
    double(:url_maker,
      published_specialist_document_path: "http://www.example.com"
    )
  }
  let(:document) {
    double(:document,
      alert_type: "drugs",
      title: "Some title",
    )
  }
  subject(:formatter) {
    MedicalSafetyAlertPublicationAlertFormatter.new(
      document: document,
      url_maker: url_maker,
    )
  }
  it "has a subject containing the document title" do
    expect(formatter.subject).to eq("Drug alert: Some title")
  end
end
