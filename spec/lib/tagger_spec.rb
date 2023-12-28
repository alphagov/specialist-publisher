require "rails_helper"

RSpec.describe Tagger do
  subject { described_class }

  before :each do
    @content_id = "64aadc14-9bca-40d9-abb4-4f21f9792a05"
    stub_publishing_api_has_links(content_id: @content_id, links: { taxons: %w[aaa bbb] }, version: 5)
    stub_any_publishing_api_patch_links
  end

  describe "#tag" do
    it "tags content to a taxon" do
      expect(subject.add_tags(@content_id) { %w[ccc ddd] }).to be true
      assert_publishing_api_patch_links(@content_id, links: { taxons: %w[ccc ddd] }, previous_version: 5, bulk_publishing: true)
    end

    it "does not tag content to a set of taxons because the content is already tagged" do
      expect(subject.add_tags(@content_id) { |ts| ts }).to be false
      assert_publishing_api_patch_links(@content_id, ->(_) { true }, 0)
    end

    it "yields existing taxons" do
      expected_existing_taxons = nil
      subject.add_tags(@content_id) do |ts|
        expected_existing_taxons = ts
      end
      expect(expected_existing_taxons).to match_array(%w[aaa bbb])
    end

    it "retries 3 times" do
      stub_any_publishing_api_patch_links.and_raise(GdsApi::HTTPConflict).times(2).then.to_return(body: "{}")
      expect { subject.add_tags(@content_id) { %w[ccc] } }.to_not raise_error

      stub_any_publishing_api_patch_links.and_raise(GdsApi::HTTPConflict).times(3).then.to_return(body: "{}")
      expect { subject.add_tags(@content_id) { %w[ccc] } }.to raise_error(GdsApi::HTTPConflict)
    end
  end
end
