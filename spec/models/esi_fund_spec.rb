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
    }
  }

  let(:esi_funds) { 10.times.map { |n| esi_fund_content_item(n) } }

  before do
    esi_funds.each do |esi_fund|
      publishing_api_has_item(esi_fund)
    end

    Timecop.freeze(Time.parse("2015-12-18 10:12:26 UTC"))
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
      esi_fund.delete("updated_at")
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
      stub_any_rummager_post_with_queueing_enabled

      esi_fund = described_class.find(esi_funds[0]["content_id"])
      expect(esi_fund.publish!).to eq(true)

      assert_publishing_api_publish(esi_fund.content_id)
      assert_rummager_posted_item(indexable_attributes)
    end
  end
end
