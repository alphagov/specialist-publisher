require "rails_helper"

RSpec.describe TaxTribunalDecision do
  def tax_tribunal_decision_content_item(n)
    Payloads.tax_tribunal_decision_content_item(
      "base_path" => "/tax-and-chancery-tribunal-decisions/example-tax-tribunal-decision-#{n}",
      "title" => "Example Tax Tribunal Decision #{n}",
      "description" => "This is the summary of example Tax Tribunal Decision #{n}",
      "routes" => [
        {
          "path" => "/tax-and-chancery-tribunal-decisions/example-tax-tribunal-decision-#{n}",
          "type" => "exact",
        }
      ]
    )
  end

  let(:tax_tribunal_decisions) { 10.times.map { |n| tax_tribunal_decision_content_item(n) } }

  before do
    tax_tribunal_decisions.each do |decision|
      publishing_api_has_item(decision)
    end

    Timecop.freeze(Time.parse("2015-12-18 10:12:26 UTC"))
  end

  describe ".find" do
    it "returns an Tax Tribunal Decision" do
      content_id = tax_tribunal_decisions[0]["content_id"]
      tax_tribunal_decision = described_class.find(content_id)

      expect(tax_tribunal_decision.base_path).to                        eq(tax_tribunal_decisions[0]["base_path"])
      expect(tax_tribunal_decision.title).to                            eq(tax_tribunal_decisions[0]["title"])
      expect(tax_tribunal_decision.summary).to                          eq(tax_tribunal_decisions[0]["description"])
      expect(tax_tribunal_decision.body).to                             eq(tax_tribunal_decisions[0]["details"]["body"][0]["content"])
      expect(tax_tribunal_decision.tribunal_decision_category).to       eq(tax_tribunal_decisions[0]["details"]["metadata"]["tribunal_decision_category"])
      expect(tax_tribunal_decision.tribunal_decision_decision_date).to  eq(tax_tribunal_decisions[0]["details"]["metadata"]["tribunal_decision_decision_date"])
    end
  end


  describe "#save!" do
    it "saves the Tax Tribunal Decision" do
      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links

      tax_tribunal_decision = tax_tribunal_decisions[0]

      tax_tribunal_decision.delete("publication_state")
      tax_tribunal_decision.delete("updated_at")
      tax_tribunal_decision.merge!("public_updated_at" => "2015-12-18T10:12:26+00:00")
      tax_tribunal_decision["details"].merge!(
        "change_history" => [
          {
            "public_timestamp" => "2015-12-18T10:12:26+00:00",
            "note" => "First published.",
          }
        ]
      )

      c = described_class.find(tax_tribunal_decision["content_id"])
      expect(c.save!).to eq(true)

      assert_publishing_api_put_content(c.content_id, request_json_includes(tax_tribunal_decision))
      expect(tax_tribunal_decision.to_json).to be_valid_against_schema('specialist_document')
    end
  end
end
