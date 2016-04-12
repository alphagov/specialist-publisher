require 'spec_helper'

describe VehicleRecallsAndFaultsAlert do
  def vehicle_recalls_and_faults_alert_content_item(n)
    Payloads.vehicle_recalls_and_faults_alert_content_item(
      "base_path" => "/vehicle-recalls-faults/example-vehicle-recalls-and-faults-#{n}",
      "title" => "Example Vehicle Recalls And Faults #{n}",
      "description" => "This is the summary of example Vehicle Recalls And Faults #{n}",
      "routes" => [
        {
          "path" => "/vehicle-recalls-faults/example-vehicle-recalls-and-faults-#{n}",
          "type" => "exact",
        }
      ]
    )
  end

  let(:vehicle_recalls_and_faults_alert_org_content_item) {
    {
      "base_path" => "/vehicle-recalls-faults",
      "content_id" => "76290530-743e-4a8c-8752-04ebee25f64a",
      "title" => "Vehicle recalls and faults",
      "format" => "placeholder_organisation",
      "need_ids" => [],
      "locale" => "en",
      "updated_at" => "2015-08-20T10:26:56.082Z",
      "public_updated_at" => "2015-04-15T10:04:28.000+00:00",
      "phase" => "live",
      "analytics_identifier" => nil,
      "links" => {
        "available_translations" => [
          {
            "content_id" => "76290530-743e-4a8c-8752-04ebee25f64a",
            "title" => "Vehicle recalls and faults",
            "base_path" => "/vehicle-recalls-faults",
            "description" => nil,
            "api_url" => "https://www.gov.uk/api/content/vehicle-recalls-faults",
            "web_url" => "https://www.gov.uk/vehicle-recalls-faults",
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
      "title" => "Example Vehicle Recalls And Faults 0",
      "description" => "This is the summary of example Vehicle Recalls And Faults 0",
      "link" => "/vehicle-recalls-faults/example-vehicle-recalls-and-faults-0",
      "indexable_content" => "## Header" + ("\r\n\r\nThis is the long body of an example Vehicle Recalls And Faults" * 10),
      "public_timestamp" => "2015-11-16T11:53:30+00:00",
      "alert_issue_date" => "2015-04-28",
      "build_start_date" => "2015-04-28",
      "build_end_date" => "2015-06-28",
    }
  }

  let(:fields) { %i[base_path content_id public_updated_at title publication_state] }
  let(:vehicle_recalls_and_faults) { 10.times.map { |n| vehicle_recalls_and_faults_alert_content_item(n) } }

  before do
    publishing_api_has_fields_for_document(described_class.publishing_api_document_type, vehicle_recalls_and_faults, fields)

    vehicle_recalls_and_faults.each do |vehicle|
      publishing_api_has_item(vehicle)
    end

    Timecop.freeze(Time.parse("2015-12-18 10:12:26 UTC"))
  end

  describe ".all" do
    it "returns all Vehicle Recalls and Faults" do
      expect(described_class.all.length).to be(vehicle_recalls_and_faults.length)
    end
  end

  describe ".find" do
    it "returns a Vehicle Recall and Fault" do
      content_id = vehicle_recalls_and_faults[0]["content_id"]
      vehicle_recall_and_fault = described_class.find(content_id)

      expect(vehicle_recall_and_fault.base_path).to            eq(vehicle_recalls_and_faults[0]["base_path"])
      expect(vehicle_recall_and_fault.title).to                eq(vehicle_recalls_and_faults[0]["title"])
      expect(vehicle_recall_and_fault.summary).to              eq(vehicle_recalls_and_faults[0]["description"])
      expect(vehicle_recall_and_fault.body).to                 eq(vehicle_recalls_and_faults[0]["details"]["body"][0]["content"])
      expect(vehicle_recall_and_fault.alert_issue_date).to     eq(vehicle_recalls_and_faults[0]["details"]["metadata"]["alert_issue_date"])
      expect(vehicle_recall_and_fault.build_start_date).to     eq(vehicle_recalls_and_faults[0]["details"]["metadata"]["build_start_date"])
      expect(vehicle_recall_and_fault.build_end_date).to       eq(vehicle_recalls_and_faults[0]["details"]["metadata"]["build_end_date"])
    end
  end

  describe "#save!" do
    it "saves the Vehicle Recall and Fault" do
      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links

      vehicle_recall_and_fault = vehicle_recalls_and_faults[0]

      vehicle_recall_and_fault.delete("publication_state")
      vehicle_recall_and_fault.merge!("public_updated_at" => "2015-12-18T10:12:26+00:00")
      vehicle_recall_and_fault["details"].merge!(
        "change_history" => [
          {
            "public_timestamp" => "2015-12-18T10:12:26+00:00",
            "note" => "First published.",
          }
        ]
      )

      c = described_class.find(vehicle_recall_and_fault["content_id"])
      expect(c.save!).to eq(true)

      assert_publishing_api_put_content(c.content_id, request_json_includes(vehicle_recall_and_fault))
      expect(vehicle_recall_and_fault.to_json).to be_valid_against_schema('specialist_document')
    end
  end

  describe "#publish!" do
    before do
      email_alert_api_accepts_alert
    end

    it "publishes the Vehicle Recall and Fault" do
      stub_publishing_api_publish(vehicle_recalls_and_faults[0]["content_id"], {})
      stub_any_rummager_post
      publishing_api_has_fields_for_document('organisation', [vehicle_recalls_and_faults_alert_org_content_item], [:base_path, :content_id])

      vehicle_recall_and_fault = described_class.find(vehicle_recalls_and_faults[0]["content_id"])
      expect(vehicle_recall_and_fault.publish!).to eq(true)

      assert_publishing_api_publish(vehicle_recall_and_fault.content_id)
      assert_rummager_posted_item(indexable_attributes)
    end
  end
end
