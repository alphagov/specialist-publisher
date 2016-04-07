require 'spec_helper'

describe EmploymentAppealTribunalDecision do
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

  let(:employment_appeal_tribunal_decision_org_content_item) {
    {
      "base_path" => "/courts-tribunals/employment-appeal-tribunal",
      "content_id" => "caeb418c-d11c-4352-92e9-47b21289f696",
      "title" => "Employment Appeal Tribunal",
      "format" => "placeholder_organisation",
      "need_ids" => [],
      "locale" => "en",
      "updated_at" => "2015-08-20T10:26:56.082Z",
      "public_updated_at" => "2015-04-15T10:04:28.000+00:00",
      "phase" => "live",
      "analytics_identifier" => "CO1134",
      "links" => {
        "available_translations" => [
          {
            "content_id" => "975cf540-6e64-40e3-b62a-df655a8c99ef",
            "title" => "Employment appeal tribunal decisions",
            "base_path" => "/employment-appeal-tribunal-decisions",
            "description" => nil,
            "api_url" => "https://www-origin.integration.publishing.service.gov.uk/api/content/employment-appeal-tribunal-decisions",
            "web_url" => "https://www-origin.integration.publishing.service.gov.uk/employment-appeal-tribunal-decisions",
            "locale" => "en"
          }
        ]
      },
      "description" => nil,
      "details" => {}
    }
  }

  let(:indexable_attributes) {
    {
      "title" => "Example Employment Appeal Tribunal Decision 0",
      "description" => "This is the summary of example Employment Appeal Tribunal Decision 0",
      "link" => "/employment-appeal-tribunal-decisions/example-employment-appeal-tribunal-decision-0",
      "indexable_content" => "## Header" + ("\r\n\r\nThis is the long body of an example Employment Appeal Tribunal Decision" * 10),
      "public_timestamp" => "2015-11-16T11:53:30+00:00",
      "tribunal_decision_categories" => ["age-discrimination"],
      "tribunal_decision_decision_date" => "2015-07-30",
      "tribunal_decision_landmark" => "landmark",
      "tribunal_decision_sub_categories" => ["contract-of-employment-apprenticeship"],
      "organisations" => ["employment-appeal-tribunal"],
    }
  }

  let(:fields) { %i[base_path content_id public_updated_at title publication_state] }

  let(:employment_appeal_tribunal_decisions) { 10.times.map { |n| employment_appeal_tribunal_decision_content_item(n) } }

  before do
    publishing_api_has_fields_for_document(described_class.publishing_api_document_type, employment_appeal_tribunal_decisions, fields)

    employment_appeal_tribunal_decisions.each do |decision|
      publishing_api_has_item(decision)
    end

    Timecop.freeze(Time.parse("2015-12-18 10:12:26 UTC"))
  end

  describe ".all" do
    it "returns all Employment Appeal Tribunal Decisions" do
      expect(described_class.all.length).to be(employment_appeal_tribunal_decisions.length)
    end
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
      stub_any_rummager_post
      publishing_api_has_fields_for_document('organisation', [employment_appeal_tribunal_decision_org_content_item], [:base_path, :content_id])

      employment_appeal_tribunal_decision = described_class.find(employment_appeal_tribunal_decisions[0]["content_id"])
      expect(employment_appeal_tribunal_decision.publish!).to eq(true)

      assert_publishing_api_publish(employment_appeal_tribunal_decision.content_id)
      assert_rummager_posted_item(indexable_attributes)
    end
  end
end
