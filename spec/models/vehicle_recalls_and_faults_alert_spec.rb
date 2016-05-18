require 'spec_helper'

RSpec.describe VehicleRecallsAndFaultsAlert do
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

  let(:vehicle_recalls_and_faults) { 10.times.map { |n| vehicle_recalls_and_faults_alert_content_item(n) } }

  before do
    vehicle_recalls_and_faults.each do |vehicle|
      publishing_api_has_item(vehicle)
    end

    Timecop.freeze(Time.parse("2015-12-18 10:12:26 UTC"))
  end

  describe "#save!" do
    it "saves the Vehicle Recall and Fault" do
      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links

      vehicle_recall_and_fault = vehicle_recalls_and_faults[0]

      vehicle_recall_and_fault.delete("publication_state")
      vehicle_recall_and_fault.delete("updated_at")
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
end
