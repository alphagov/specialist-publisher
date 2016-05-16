require 'spec_helper'

RSpec.describe EmploymentAppealTribunalDecision do
  def employment_appeal_tribunal_decision_content_item(n)
    Payloads.employment_appeal_tribunal_decision_content_item(
      "base_path" => "/employment-appeal-tribunal-decisions/example-employment-appeal-tribunal-decision-#{n}",
      "title" => "Example Employment Appeal Tribunal Decision #{n}",
      "description" => "This is the summary of example Employment Appeal Tribunal Decision #{n}",
      "routes" => [
        {
          "path" => "/employment-appeal-tribunal-decisions/example-employment-appeal-tribunal-decision-#{n}",
          "type" => "exact",
        }
      ]
    )
  end

  let(:indexable_attributes) {
    {
      "title" => "Example Employment Appeal Tribunal Decision 0",
      "description" => "This is the summary of example Employment Appeal Tribunal Decision 0",
      "link" => "/employment-appeal-tribunal-decisions/example-employment-appeal-tribunal-decision-0",
      "indexable_content" => "Header " + (["This is the long body of an example Employment Appeal Tribunal Decision"] * 10).join(" "),
      "public_timestamp" => "2015-11-16T11:53:30+00:00",
      "tribunal_decision_categories" => ["age-discrimination"],
      "tribunal_decision_decision_date" => "2015-07-30",
      "tribunal_decision_landmark" => "landmark",
      "tribunal_decision_sub_categories" => ["contract-of-employment-apprenticeship"],
    }
  }

  let(:employment_appeal_tribunal_decisions) { 10.times.map { |n| employment_appeal_tribunal_decision_content_item(n) } }

  before do
    employment_appeal_tribunal_decisions.each do |decision|
      publishing_api_has_item(decision)
    end

    Timecop.freeze(Time.parse("2015-12-18 10:12:26 UTC"))
  end

  describe ".find" do
    it "returns an Employment Appeal Tribunal Decision" do
      content_id = employment_appeal_tribunal_decisions[0]["content_id"]
      employment_appeal_tribunal_decision = described_class.find(content_id)

      expect(employment_appeal_tribunal_decision.base_path).to                          eq(employment_appeal_tribunal_decisions[0]["base_path"])
      expect(employment_appeal_tribunal_decision.title).to                              eq(employment_appeal_tribunal_decisions[0]["title"])
      expect(employment_appeal_tribunal_decision.summary).to                            eq(employment_appeal_tribunal_decisions[0]["description"])
      expect(employment_appeal_tribunal_decision.body).to                               eq(employment_appeal_tribunal_decisions[0]["details"]["body"][0]["content"])
      expect(employment_appeal_tribunal_decision.tribunal_decision_categories).to       eq(employment_appeal_tribunal_decisions[0]["details"]["metadata"]["tribunal_decision_categories"])
      expect(employment_appeal_tribunal_decision.tribunal_decision_decision_date).to    eq(employment_appeal_tribunal_decisions[0]["details"]["metadata"]["tribunal_decision_decision_date"])
      expect(employment_appeal_tribunal_decision.tribunal_decision_landmark).to         eq(employment_appeal_tribunal_decisions[0]["details"]["metadata"]["tribunal_decision_landmark"])
      expect(employment_appeal_tribunal_decision.tribunal_decision_sub_categories).to eq(employment_appeal_tribunal_decisions[0]["details"]["metadata"]["tribunal_decision_sub_categories"])
    end
  end

  describe "#save!" do
    it "saves the Employment Appeal Tribunal Decision" do
      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links

      employment_appeal_tribunal_decision = employment_appeal_tribunal_decisions[0]

      employment_appeal_tribunal_decision.delete("publication_state")
      employment_appeal_tribunal_decision.delete("updated_at")
      employment_appeal_tribunal_decision.merge!("public_updated_at" => "2015-12-18T10:12:26+00:00")
      employment_appeal_tribunal_decision["details"].merge!(
        "change_history" => [
          {
            "public_timestamp" => "2015-12-18T10:12:26+00:00",
            "note" => "First published.",
          }
        ]
      )

      c = described_class.find(employment_appeal_tribunal_decision["content_id"])
      expect(c.save!).to eq(true)

      assert_publishing_api_put_content(c.content_id, request_json_includes(employment_appeal_tribunal_decision))
      expect(employment_appeal_tribunal_decision.to_json).to be_valid_against_schema('specialist_document')
    end
  end

  describe "#publish!" do
    before do
      email_alert_api_accepts_alert
    end

    it "publishes the Employment Appeal Tribunal Decision" do
      stub_publishing_api_publish(employment_appeal_tribunal_decisions[0]["content_id"], {})
      stub_any_rummager_post_with_queueing_enabled

      employment_appeal_tribunal_decision = described_class.find(employment_appeal_tribunal_decisions[0]["content_id"])
      expect(employment_appeal_tribunal_decision.publish!).to eq(true)

      assert_publishing_api_publish(employment_appeal_tribunal_decision.content_id)
      assert_rummager_posted_item(indexable_attributes)
    end
  end
end
