require "spec_helper"
require "models/valid_against_schema"

RSpec.describe LicenceTransaction do
  let(:payload) { FactoryBot.create(:licence_transaction) }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"

  it "is not exportable" do
    expect(subject.class).not_to be_exportable
  end

  it "should have a rendering app of frontend" do
    expect(subject.rendering_app).to eq "frontend"
  end

  context "when the licence is validated" do
    before do
      subject.body = "body"
      subject.title = "title"
      subject.summary = "description"
      subject.licence_transaction_industry = %w[some-industry]
      subject.licence_transaction_location = %w[england]
      subject.primary_publishing_organisation = %w[af07d5a5-df63-4ddc-9383-6a666845ebe9]
    end

    it "is valid with a link and continue on text" do
      subject.licence_transaction_will_continue_on = "GDS"
      subject.licence_transaction_continuation_link = "https://www.gov.uk/random"

      expect(subject).to be_valid
    end

    it "is valid with a unique identifier" do
      stub_publishing_api_has_content([payload], hash_including(document_type: "licence_transaction"))

      subject.licence_transaction_licence_identifier = "7777-7-7"

      expect(subject).to be_valid
    end

    it "is valid when continuation link is a link" do
      subject.licence_transaction_will_continue_on = "GDS"
      subject.licence_transaction_continuation_link = "https://www.gov.uk"

      expect(subject).to be_valid
    end

    it "is invalid when continuation link isn't a link" do
      subject.licence_transaction_will_continue_on = "GDS"
      subject.licence_transaction_continuation_link = "not-a-link.abc"

      expect(subject).to be_invalid
      expect(subject.errors[:licence_transaction_continuation_link]).to eq(
        [subject.errors.generate_message(:licence_transaction_continuation_link, :invalid)],
      )
    end
  end
end
