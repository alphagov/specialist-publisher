require 'spec_helper'
require 'models/valid_against_schema'

RSpec.describe DfidResearchOutput do
  let(:payload) { FactoryBot.create(:dfid_research_output) }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"

  it 'is not exportable' do
    expect(described_class).not_to be_exportable
  end

  it 'is always bulk published to hide the publishing-api published date' do
    expect(subject.bulk_published).to be true
  end

  it "has a dfid_author_tags virtual attribute" do
    subject.dfid_author_tags = "a, b::c"
    expect(subject.dfid_authors).to eq ["a, b", "c"]

    subject.dfid_authors = ["foo, bar", "baz"]
    expect(subject.dfid_author_tags).to eq "foo, bar::baz"

    subject = described_class.new(dfid_author_tags: "foo, bar::baz")
    expect(subject.dfid_authors).to eq ["foo, bar", "baz"]
  end
end
