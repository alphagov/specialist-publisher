require 'spec_helper'

describe MedicalSafetyAlert do
  def medical_safety_alert_content_item(n)
    Payloads.medical_safety_alert_content_item(
      "base_path" => "/drug-device-alerts/example-medical-safety-alert-#{n}",
      "title" => "Example Medical Safety Alert #{n}",
      "description" => "This is the summary of example Medical Safety Alert #{n}",
      "routes" => [
        {
          "path" => "/drug-device-alerts/example-medical-safety-alert-#{n}",
          "type" => "exact",
        }
      ]
    )
  end

  let(:indexable_attributes) {
    {
      "title" => "Example Medical Safety Alert 0",
      "description" => "This is the summary of example Medical Safety Alert 0",
      "link" => "/drug-device-alerts/example-medical-safety-alert-0",
      "indexable_content" => "## Header" + ("\r\n\r\nThis is the long body of an example Medical Safety Alert" * 10),
      "public_timestamp" => "2015-11-16T11:53:30+00:00",
      "alert_type" => "company-led-drugs",
      "issued_date" => "2016-02-01",
    }
  }

  let(:medical_safety_alerts) { 10.times.map { |n| medical_safety_alert_content_item(n) } }

  before do
    medical_safety_alerts.each do |medical_safety_alert|
      publishing_api_has_item(medical_safety_alert)
    end

    Timecop.freeze(Time.parse("2015-12-18 10:12:26 UTC"))
  end

  describe ".find" do
    it "returns a Medical Safety Alert" do
      content_id = medical_safety_alerts[0]["content_id"]
      medical_safety_alert = described_class.find(content_id)

      expect(medical_safety_alert.base_path).to            eq(medical_safety_alerts[0]["base_path"])
      expect(medical_safety_alert.title).to                eq(medical_safety_alerts[0]["title"])
      expect(medical_safety_alert.summary).to              eq(medical_safety_alerts[0]["description"])
      expect(medical_safety_alert.body).to                 eq(medical_safety_alerts[0]["details"]["body"][0]["content"])
      expect(medical_safety_alert.alert_type).to           eq(medical_safety_alerts[0]["details"]["metadata"]["alert_type"])
    end
  end

  describe "#save!" do
    it "saves the Medical Safety Alert" do
      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links

      medical_safety_alert = medical_safety_alerts[0]

      medical_safety_alert.delete("publication_state")
      medical_safety_alert.delete("updated_at")
      medical_safety_alert.merge!("public_updated_at" => "2015-12-18T10:12:26+00:00")
      medical_safety_alert["details"].merge!(
        "change_history" => [
          {
            "public_timestamp" => "2015-12-18T10:12:26+00:00",
            "note" => "First published.",
          }
        ]
      )

      c = described_class.find(medical_safety_alert["content_id"])
      expect(c.save!).to eq(true)

      assert_publishing_api_put_content(c.content_id, request_json_includes(medical_safety_alert))
      expect(medical_safety_alert.to_json).to be_valid_against_schema('specialist_document')
    end
  end

  describe "#publish!" do
    before do
      email_alert_api_accepts_alert
    end

    it "publishes the Medical Safety Alert" do
      stub_publishing_api_publish(medical_safety_alerts[0]["content_id"], {})
      stub_any_rummager_post_with_queueing_enabled

      medical_safety_alert = described_class.find(medical_safety_alerts[0]["content_id"])
      expect(medical_safety_alert.publish!).to eq(true)

      assert_publishing_api_publish(medical_safety_alert.content_id)
      assert_rummager_posted_item(indexable_attributes)
    end
  end
end
