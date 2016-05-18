require 'spec_helper'

RSpec.describe EsiFund do
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
end
