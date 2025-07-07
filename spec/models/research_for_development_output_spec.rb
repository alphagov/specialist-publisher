require "spec_helper"
require "models/valid_against_schema"

RSpec.describe ResearchForDevelopmentOutput do
  let(:payload) { FactoryBot.create(:research_for_development_output) }

  it "is always bulk published to hide the publishing-api published date" do
    expect(subject.bulk_published).to be true
  end

  it "has a legacy author_tags virtual attribute" do
    subject.author_tags = "a, b::c"
    expect(subject.authors).to eq ["a, b", "c"]

    subject.authors = ["foo, bar", "baz"]
    expect(subject.author_tags).to eq "foo, bar::baz"

    subject = described_class.new(author_tags: "foo, bar::baz")
    expect(subject.authors).to eq ["foo, bar", "baz"]
  end

  it "has an author_tags virtual attribute" do
    allow_any_instance_of(described_class).to receive(:is_using_design_system_view).and_return(true)

    subject.author_tags = "a b\r\nc, d\r\n\r\n\   \r\nd. e, f"
    expect(subject.authors).to eq ["a b", "c, d", "d. e, f"]

    subject.authors = ["foo, bar", "bar. baz", "baz"]
    expect(subject.author_tags).to eq "foo, bar\r\nbar. baz\r\nbaz"

    subject = described_class.new(author_tags: "foo bar\r\nbar, baz\r\nbaz. qux\r\nqux")
    expect(subject.authors).to eq ["foo bar", "bar, baz", "baz. qux", "qux"]
  end
end
