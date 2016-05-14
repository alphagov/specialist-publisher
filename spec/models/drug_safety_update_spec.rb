require 'spec_helper'

RSpec.describe DrugSafetyUpdate do
  def drug_safety_update_content_item(n)
    Payloads.drug_safety_update_content_item(
      "base_path" => "/drug-safety-update/example-drug-safety-update-#{n}",
      "title" => "Example Drug Safety Update #{n}",
      "description" => "This is the summary of an example Drug Safety Update #{n}",
      "routes" => [
        {
          "path" => "/drug-safety-update/example-drug-safety-update-#{n}",
          "type" => "exact",
        }
      ]
    )
  end

  let(:indexable_attributes) {
    {
      "title" => "Example Drug Safety Update 0",
      "description" => "This is the summary of an example Drug Safety Update 0",
      "link" => "/drug-safety-update/example-drug-safety-update-0",
      "indexable_content" => "## Header" + ("\r\n\r\nThis is the long body of an example Drug Safety Update" * 10),
      "public_timestamp" => "2015-11-16T11:53:30+00:00",
    }
  }

  let(:drug_safety_updates) { 10.times.map { |n| drug_safety_update_content_item(n) } }

  before do
    drug_safety_updates.each do |drug_safety_update|
      publishing_api_has_item(drug_safety_update)
    end

    Timecop.freeze(Time.parse("2015-12-18 10:12:26 UTC"))
  end

  describe ".find" do
    it "returns a Drug Safety Update" do
      content_id = drug_safety_updates[0]["content_id"]
      drug_safety_update = described_class.find(content_id)

      expect(drug_safety_update.base_path).to            eq(drug_safety_updates[0]["base_path"])
      expect(drug_safety_update.title).to                eq(drug_safety_updates[0]["title"])
      expect(drug_safety_update.summary).to              eq(drug_safety_updates[0]["description"])
      expect(drug_safety_update.body).to                 eq(drug_safety_updates[0]["details"]["body"][0]["content"])
    end
  end

  describe "#save!" do
    it "saves the Drug Safety Update" do
      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links

      drug_safety_update = drug_safety_updates[0]

      drug_safety_update.delete("publication_state")
      drug_safety_update.delete("updated_at")
      drug_safety_update.merge!("public_updated_at" => "2015-12-18T10:12:26+00:00")
      drug_safety_update["details"].merge!(
        "change_history" => [
          {
            "public_timestamp" => "2015-12-18T10:12:26+00:00",
            "note" => "First published.",
          }
        ]
      )

      c = described_class.find(drug_safety_update["content_id"])
      expect(c.save!).to eq(true)

      assert_publishing_api_put_content(c.content_id, request_json_includes(drug_safety_update))
      expect(drug_safety_update.to_json).to be_valid_against_schema('specialist_document')
    end
  end

  describe "#publish!" do
    let(:unpublished_drug_safety_update_content_item) { drug_safety_update_content_item(0) }
    let(:published_drug_safety_update_content_item) {
      drug_safety_update_content_item(0).deep_merge(
        "details" => {
          "metadata" => {
            "first_published_at": "2015-12-18T10:12:26.000+00:00",
            "document_type": "drug_safety_update"
          }
        },
        "publication_state" => "live"
      )
    }

    before do
      email_alert_api_accepts_alert
      allow(Time.zone).to receive(:now).and_return(Time.parse("2015-12-18T10:12:26.000+00:00"))
      stub_any_rummager_post_with_queueing_enabled
      stub_any_publishing_api_put_content

      publishing_api_has_item(unpublished_drug_safety_update_content_item)
      publishing_api_has_item(published_drug_safety_update_content_item)
    end

    let(:drug_safety_update) { described_class.find(drug_safety_updates[0]["content_id"]) }

    it "publishes the Drug Safety Update" do
      payload = unpublished_drug_safety_update_content_item

      stub_publishing_api_publish(payload["content_id"], {})

      drug_safety_update = described_class.find(payload["content_id"])

      expect(drug_safety_update.publish!).to eq(true)

      assert_publishing_api_publish(drug_safety_update.content_id)
      assert_rummager_posted_item(indexable_attributes)
      assert_not_requested(:post, Plek.current.find('email-alert-api') + "/notifications")
    end

    it "notifies Airbrake and returns false if publishing-api does not return status 200" do
      expect(Airbrake).to receive(:notify)
      stub_publishing_api_publish(drug_safety_updates[0]["content_id"], {}, status: 503)
      stub_any_rummager_post_with_queueing_enabled
      expect(drug_safety_update.publish!).to eq(false)
    end

    it "notifies Airbrake and returns false if rummager does not return status 200" do
      expect(Airbrake).to receive(:notify)
      stub_publishing_api_publish(drug_safety_updates[0]["content_id"], {})
      stub_request(:post, %r{#{Plek.new.find('search')}/documents}).to_return(status: 503)
      expect(drug_safety_update.publish!).to eq(false)
    end

    context "for the first time" do
      it "sets first_published_at" do
        payload = unpublished_drug_safety_update_content_item

        stub_publishing_api_publish(payload["content_id"], {})

        drug_safety_update = described_class.find(payload["content_id"])
        expect(drug_safety_update.publish!).to eq(true)

        expected_details_payload = payload["details"]
        expected_details_payload["metadata"].merge!(
          "first_published_at" => "2015-12-18T10:12:26.000+00:00"
        )

        assert_publishing_api_put_content(
          drug_safety_update.content_id,
          request_json_includes("details": expected_details_payload)
        )
      end
    end

    context "an already published drug safety update" do
      it "does not update first_published_at" do
        payload = published_drug_safety_update_content_item

        stub_publishing_api_publish(payload["content_id"], {})

        drug_safety_update = described_class.find(payload["content_id"])
        expect(drug_safety_update.publish!).to eq(true)

        assert_not_requested(:put, "#{Plek.current.find('publishing-api')}/v2/content/#{payload['content_id']}")
        assert_publishing_api_publish(drug_safety_update.content_id)
      end
    end
  end
end
