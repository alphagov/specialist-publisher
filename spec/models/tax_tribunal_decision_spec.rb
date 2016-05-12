require "rails_helper"

describe TaxTribunalDecision do
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

  let(:indexable_attributes) {
    {
      "title" => "Example Tax Tribunal Decision 0",
      "description" => "This is the summary of example Tax Tribunal Decision 0",
      "link" => "/tax-and-chancery-tribunal-decisions/example-tax-tribunal-decision-0",
      "indexable_content" => "## Header" + ("\r\n\r\nThis is the long body of an example Tax Tribunal Decision" * 10),
      "public_timestamp" => "2015-11-16T11:53:30+00:00",
      "tribunal_decision_category" => "banking",
      "tribunal_decision_decision_date" => "2015-07-30",
    }
  }

  let(:fields) { %i[base_path content_id public_updated_at title publication_state] }
  let(:tax_tribunal_decisions) { 10.times.map { |n| tax_tribunal_decision_content_item(n) } }
  let(:page) { 1 }
  let(:per_page) { 50 }

  before do
    publishing_api_has_content(tax_tribunal_decisions, hash_including(document_type: described_class.publishing_api_document_type))

    tax_tribunal_decisions.each do |decision|
      publishing_api_has_item(decision)
    end

    Timecop.freeze(Time.parse("2015-12-18 10:12:26 UTC"))
  end

  describe ".all" do
    it "returns all Tax Tribunal Decisions" do
      expect(described_class.all(page, per_page).results.length).to be(tax_tribunal_decisions.length)
    end
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

  describe "#publish!" do
    before do
      email_alert_api_accepts_alert
    end

    it "publishes the Tax Tribunal Decision" do
      stub_publishing_api_publish(tax_tribunal_decisions[0]["content_id"], {})
      stub_any_rummager_post_with_queueing_enabled

      tax_tribunal_decision = described_class.find(tax_tribunal_decisions[0]["content_id"])
      expect(tax_tribunal_decision.publish!).to eq(true)

      assert_publishing_api_publish(tax_tribunal_decision.content_id)
      assert_rummager_posted_item(indexable_attributes)
    end
  end
end
