require 'spec_helper'

describe EsiFund do
  def esi_fund_content_item(n)
    Payloads.esi_fund_content_item(
      "base_path" => "/european-structural-investment-funds/example-esi-fund-#{n}",
      "title" => "Example ESI Fund #{n}",
      "description" => "This is the summary of example ESI Fund #{n}",
      "routes" => [
        {
          "path" => "/european-structural-investment-funds/example-esi-fund-#{n}",
          "type" => "exact",
        },
      ]
    )
  end

  let(:esi_fund_org_content_items) {
    [
      {
        "content_id" => "2e7868a8-38f5-4ff6-b62f-9a15d1c22d28",
        "title" => "Department for Communities and Local Government",
        "base_path" => "/government/organisations/department-for-communities-and-local-government",
        "description" => nil,
        "api_url" => "https://www.gov.uk/api/content/government/organisations/department-for-communities-and-local-government",
        "web_url" => "https://www.gov.uk/government/organisations/department-for-communities-and-local-government",
        "locale" => "en",
        "analytics_identifier" => "D4"
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
        "content_id" => "569a9ee5-c195-4b7f-b9dc-edc17a09113f",
        "title" => "Department for Business, Innovation & Skills",
        "base_path" => "/government/organisations/department-for-business-innovation-skills",
        "description" => nil,
        "api_url" => "https://www.gov.uk/api/content/government/organisations/department-for-business-innovation-skills",
        "web_url" => "https://www.gov.uk/government/organisations/department-for-business-innovation-skills",
        "locale" => "en",
        "analytics_identifier" => "D3"
      },
      {
        "content_id" => "b548a09f-8b35-4104-89f4-f1a40bf3136d",
        "title" => "Department for Work and Pensions",
        "base_path" => "/government/organisations/department-for-work-pensions",
        "description" => nil,
        "api_url" => "https://www.gov.uk/api/content/government/organisations/department-for-work-pensions",
        "web_url" => "https://www.gov.uk/government/organisations/department-for-work-pensions",
        "locale" => "en",
        "analytics_identifier" => "D10"
      }
    ]
  }

  let(:indexable_attributes) {
    {
      "title" => "Example ESI Fund 0",
      "description" => "This is the summary of example ESI Fund 0",
      "link" => "/european-structural-investment-funds/example-esi-fund-0",
      "indexable_content" => "## Header" + ("\r\n\r\nThis is the long body of an example ESI Fund" * 10),
      "public_timestamp" => "2015-11-16T11:53:30+00:00",
      "fund_state" => nil,
      "fund_type" => nil,
      "location" => nil,
      "funding_source" => nil,
      "closing_date" => "2016-01-01",
      "organisations" => ["department-for-communities-and-local-government", "department-for-environment-food-rural-affairs", "department-for-business-innovation-skills", "department-for-work-pensions"],
    }
  }

  let(:fields) { %i[base_path content_id public_updated_at title publication_state] }

  let(:esi_funds) { 10.times.map { |n| esi_fund_content_item(n) } }

  before do
    publishing_api_has_fields_for_document(described_class.publishing_api_document_type, esi_funds, fields)

    esi_funds.each do |esi_fund|
      publishing_api_has_item(esi_fund)
    end

    Timecop.freeze(Time.parse("2015-12-18 10:12:26 UTC"))
  end

  context ".all" do
    it "returns all ESI Funds" do
      expect(described_class.all.length).to be(esi_funds.length)
    end
  end

  context ".find" do
    it "returns an ESI Fund" do
      content_id = esi_funds[0]["content_id"]
      esi_fund = described_class.find(content_id)

      expect(esi_fund.base_path).to            eq(esi_funds[0]["base_path"])
      expect(esi_fund.title).to                eq(esi_funds[0]["title"])
      expect(esi_fund.summary).to              eq(esi_funds[0]["description"])
      expect(esi_fund.body).to                 eq(esi_funds[0]["details"]["body"][0]["content"])
      expect(esi_fund.closing_date).to         eq(esi_funds[0]["details"]['metadata']["closing_date"])
    end
  end

  describe "#save!" do
    it "saves the ESI Fund" do
      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links

      esi_fund = esi_funds[0]

      esi_fund.delete("publication_state")
      esi_fund.merge!("public_updated_at" => "2015-12-18T10:12:26+00:00")
      esi_fund["details"].merge!(
        "change_history" => [
          {
            "public_timestamp" => "2015-12-18T10:12:26+00:00",
            "note" => "First published.",
          }
        ]
      )

      c = described_class.find(esi_fund["content_id"])
      expect(c.save!).to eq(true)

      assert_publishing_api_put_content(c.content_id, request_json_includes(esi_fund))
      expect(esi_fund.to_json).to be_valid_against_schema('specialist_document')
    end
  end

  describe "#publish!" do
    before do
      email_alert_api_accepts_alert
    end

    it "publishes the ESI Fund" do
      stub_publishing_api_publish(esi_funds[0]["content_id"], {})
      stub_any_rummager_post
      publishing_api_has_fields_for_document('organisation', esi_fund_org_content_items, [:base_path, :content_id])

      esi_fund = described_class.find(esi_funds[0]["content_id"])
      expect(esi_fund.publish!).to eq(true)

      assert_publishing_api_publish(esi_fund.content_id)
      assert_rummager_posted_item(indexable_attributes)
    end
  end
end
