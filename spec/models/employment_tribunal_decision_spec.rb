require 'spec_helper'

RSpec.describe EmploymentTribunalDecision do
  def employment_tribunal_decision_content_item(n)
    Payloads.employment_tribunal_decision_content_item(
      "base_path" => "/employment-tribunal-decisions/example-employment-tribunal-decision-#{n}",
      "title" => "Example Employment Tribunal Decision #{n}",
      "description" => "This is the summary of example Employment Tribunal Decision #{n}",
      "routes" => [
        {
          "path" => "/employment-tribunal-decisions/example-employment-tribunal-decision-#{n}",
          "type" => "exact",
        }
      ]
    )
  end

  let(:employment_tribunal_decisions) { 10.times.map { |n| employment_tribunal_decision_content_item(n) } }

  before do
    employment_tribunal_decisions.each do |decision|
      publishing_api_has_item(decision)
    end

    Timecop.freeze(Time.parse("2015-12-18 10:12:26 UTC"))
  end

  describe "#save!" do
    it "saves the Employment Tribunal Decision" do
      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links

      employment_tribunal_decision = employment_tribunal_decisions[0]

      employment_tribunal_decision.delete("publication_state")
      employment_tribunal_decision.delete("updated_at")
      employment_tribunal_decision.merge!("public_updated_at" => "2015-12-18T10:12:26+00:00")
      employment_tribunal_decision["details"].merge!(
        "change_history" => [
          {
            "public_timestamp" => "2015-12-18T10:12:26+00:00",
            "note" => "First published.",
          }
        ]
      )

      c = described_class.find(employment_tribunal_decision["content_id"])
      expect(c.save!).to eq(true)

      assert_publishing_api_put_content(c.content_id, request_json_includes(employment_tribunal_decision))
      expect(employment_tribunal_decision.to_json).to be_valid_against_schema('specialist_document')
    end
  end
end
