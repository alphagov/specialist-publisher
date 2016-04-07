require 'spec_helper'

describe CountrysideStewardshipGrant do
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

  let(:countryside_stewardship_grant_org_content_items) {
    [
      {
        "content_id" => "d3ce4ba7-bc75-46b4-89d9-38cb3240376d",
        "title" => "Natural England",
        "base_path" => "/government/organisations/natural-england",
        "description" => nil,
        "api_url" => "https://www.gov.uk/api/content/government/organisations/natural-england",
        "web_url" => "https://www.gov.uk/government/organisations/natural-england",
        "locale" => "en",
        "analytics_identifier" => "PB202"
      },
      {
        "content_id" => "de4e9dc6-cca4-43af-a594-682023b84d6c",
        "title" => "Department for Environment, Food & Rural Affairs",
        "base_path" => "/government/organisations/department-for-environment-food-rural-affairs",
        "description" => nil,
        "api_url" => "https://www.gov.uk/api/content/government/organisations/department-for-environment-food-rural-affairs",
        "web_url" => "https://www.gov.uk/government/organisations/department-for-environment-food-rural-affairs",
        "locale" => "en",
        "analytics_identifier" => "D7"
      },
      {
        "content_id" => "8bf5624b-dec2-44fa-9b6c-daed166333a5",
        "title" => "Forestry Commission",
        "base_path" => "/government/organisations/forestry-commission",
        "description" => nil,
        "api_url" => "https://www.gov.uk/api/content/government/organisations/forestry-commission",
        "web_url" => "https://www.gov.uk/government/organisations/forestry-commission",
        "locale" => "en",
        "analytics_identifier" => "D85"
      },
    ]
  }

  let(:indexable_attributes) {
    {
      "title" => "Example Countryside Stewardship Grant 0",
      "description" => "This is the summary of example Countryside Stewardship Grant 0",
      "link" => "/countryside-stewardship-grants/example-countryside-stewardship-grant-0",
      "indexable_content" => "## Header" + ("\r\n\r\nThis is the long body of an example Countryside Stewardship Grant" * 10),
      "public_timestamp" => "2015-11-16T11:53:30+00:00",
      "organisations" => ["natural-england", "department-for-environment-food-rural-affairs", "forestry-commission"],
    }
  }

  let(:fields) { %i[base_path content_id public_updated_at title publication_state] }

  let(:countryside_stewardship_grants) { 10.times.map { |n| countryside_stewardship_grant_content_item(n) } }

  before do
    publishing_api_has_fields_for_document(described_class.publishing_api_document_type, countryside_stewardship_grants, fields)

    countryside_stewardship_grants.each do |countryside_stewardship_grant|
      publishing_api_has_item(countryside_stewardship_grant)
    end

    Timecop.freeze("2015-12-18 10:12:26 UTC")
  end

  describe ".all" do
    it "returns all Countryside Stewardship Grants" do
      expect(described_class.all.length).to be(countryside_stewardship_grants.length)
    end
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
      stub_any_rummager_post
      publishing_api_has_fields_for_document('organisation', countryside_stewardship_grant_org_content_items, [:base_path, :content_id])

      countryside_stewardship_grant = described_class.find(countryside_stewardship_grants[0]["content_id"])
      expect(countryside_stewardship_grant.publish!).to eq(true)

      assert_publishing_api_publish(countryside_stewardship_grant.content_id)
      assert_rummager_posted_item(indexable_attributes)
    end
  end
end
