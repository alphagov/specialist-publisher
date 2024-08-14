require "spec_helper"
require "models/valid_against_schema"

RSpec.describe SpecialistDocument::DrugSafetyUpdate do
  let(:payload) { FactoryBot.create(:drug_safety_update) }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"

  it "is not exportable" do
    expect(described_class).not_to be_exportable
  end

  context "#publish" do
    let(:payload) do
      FactoryBot.create(
        :drug_safety_update,
        :published,
        update_type: "major",
      )
    end
    let(:document) { described_class.from_publishing_api(payload) }

    it "doesn't notify the Email Alert API on major updates" do
      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links

      stub_publishing_api_has_item(payload)
      stub_publishing_api_publish(payload["content_id"], {})

      document.publish

      assert_publishing_api_publish(payload["content_id"])
      assert_not_requested(:post, "#{Plek.find('email-alert-api')}/notifications")
    end
  end
end
