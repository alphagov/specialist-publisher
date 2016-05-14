require 'spec_helper'

RSpec.describe CountrysideStewardshipGrant do
  def countryside_stewardship_grant_content_item(n)
    Payloads.countryside_stewardship_grant_content_item(
      "base_path" => "/countryside-stewardship-grants/example-countryside-stewardship-grant-#{n}",
      "title" => "Example Countryside Stewardship Grant #{n}",
      "description" => "This is the summary of example Countryside Stewardship Grant #{n}",
      "routes" => [
        {
          "path" => "/countryside-stewardship-grants/example-countryside-stewardship-grant-#{n}",
          "type" => "exact",
        }
      ]
    )
  end

  let(:indexable_attributes) {
    {
      "title" => "Example Countryside Stewardship Grant 0",
      "description" => "This is the summary of example Countryside Stewardship Grant 0",
      "link" => "/countryside-stewardship-grants/example-countryside-stewardship-grant-0",
      "indexable_content" => "## Header" + ("\r\n\r\nThis is the long body of an example Countryside Stewardship Grant" * 10),
      "public_timestamp" => "2015-11-16T11:53:30+00:00",
    }
  }

  let(:countryside_stewardship_grants) { 10.times.map { |n| countryside_stewardship_grant_content_item(n) } }

  before do
    countryside_stewardship_grants.each do |countryside_stewardship_grant|
      publishing_api_has_item(countryside_stewardship_grant)
    end

    Timecop.freeze("2015-12-18 10:12:26 UTC")
  end

  describe ".find" do
    it "returns a Countryside Stewardship Grant" do
      content_id = countryside_stewardship_grants[0]["content_id"]
      countryside_stewardship_grant = described_class.find(content_id)

      expect(countryside_stewardship_grant.base_path).to eq(countryside_stewardship_grants[0]["base_path"])
      expect(countryside_stewardship_grant.title).to eq(countryside_stewardship_grants[0]["title"])
      expect(countryside_stewardship_grant.summary).to eq(countryside_stewardship_grants[0]["description"])
      expect(countryside_stewardship_grant.body).to eq(countryside_stewardship_grants[0]["details"]["body"][0]["content"])
    end
  end

  describe "#save!" do
    it "saves the Countryside Stewardship Grant" do
      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links

      countryside_stewardship_grant = countryside_stewardship_grants[0]

      countryside_stewardship_grant.delete("publication_state")
      countryside_stewardship_grant.delete("updated_at")
      countryside_stewardship_grant.merge!("public_updated_at" => "2015-12-18T10:12:26+00:00")
      countryside_stewardship_grant["details"].merge!(
        "change_history" => [
          {
            "public_timestamp" => "2015-12-18T10:12:26+00:00",
            "note" => "First published.",
          }
        ]
      )

      c = described_class.find(countryside_stewardship_grant["content_id"])
      expect(c.save!).to eq(true)

      assert_publishing_api_put_content(c.content_id, request_json_includes(countryside_stewardship_grant))
      expect(countryside_stewardship_grant.to_json).to be_valid_against_schema('specialist_document')
    end
  end

  describe "#publish!" do
    before do
      email_alert_api_accepts_alert
    end

    it "publishes the Countryside Stewardship Grant" do
      stub_publishing_api_publish(countryside_stewardship_grants[0]["content_id"], {})
      stub_any_rummager_post_with_queueing_enabled

      countryside_stewardship_grant = described_class.find(countryside_stewardship_grants[0]["content_id"])
      expect(countryside_stewardship_grant.publish!).to eq(true)

      assert_publishing_api_publish(countryside_stewardship_grant.content_id)
      assert_rummager_posted_item(indexable_attributes)
    end
  end
end
