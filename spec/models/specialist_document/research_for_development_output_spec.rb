require "spec_helper"
require "models/valid_against_schema"

RSpec.describe SpecialistDocument::ResearchForDevelopmentOutput do
  let(:payload) { FactoryBot.create(:research_for_development_output) }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"

  it "is not exportable" do
    expect(described_class).not_to be_exportable
  end

  it "is always bulk published to hide the publishing-api published date" do
    expect(subject.bulk_published).to be true
  end

  it "has a author_tags virtual attribute" do
    subject.author_tags = "a, b::c"
    expect(subject.authors).to eq ["a, b", "c"]

    subject.authors = ["foo, bar", "baz"]
    expect(subject.author_tags).to eq "foo, bar::baz"

    subject = described_class.new(author_tags: "foo, bar::baz")
    expect(subject.authors).to eq ["foo, bar", "baz"]
  end
end
