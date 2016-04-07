require 'spec_helper'

describe DrugSafetyUpdate do
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

  let(:drug_safety_update_org_content_item) {
    {
      "base_path" => "/government/organisations/medicines-and-healthcare-products-regulatory-agency",
      "content_id" => "240f72bd-9a4d-4f39-94d9-77235cadde8e",
      "title" => "Medicines and Healthcare products Regulatory Agency",
      "format" => "placeholder_organisation",
      "need_ids" => [],
      "locale" => "en",
      "updated_at" => "2015-08-20T10:26:56.082Z",
      "public_updated_at" => "2015-04-15T10:04:28.000+00:00",
      "phase" => "live",
      "analytics_identifier" => "A63",
      "links" => {
        "available_translations" => [
          {
            "content_id" => "240f72bd-9a4d-4f39-94d9-77235cadde8e",
            "title" => "Medicines and Healthcare products Regulatory Agency",
            "base_path" => "/government/organisations/medicines-and-healthcare-products-regulatory-agency",
            "description" => nil,
            "api_url" => "https://www.gov.uk/api/content/government/organisations/medicines-and-healthcare-products-regulatory-agency",
            "web_url" => "https://www.gov.uk/government/organisations/medicines-and-healthcare-products-regulatory-agency",
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
      "title" => "Example Drug Safety Update 0",
      "description" => "This is the summary of an example Drug Safety Update 0",
      "link" => "/drug-safety-update/example-drug-safety-update-0",
      "indexable_content" => "## Header" + ("\r\n\r\nThis is the long body of an example Drug Safety Update" * 10),
      "public_timestamp" => "2015-11-16T11:53:30+00:00",
      "organisations" => ["medicines-and-healthcare-products-regulatory-agency"],
    }
  }

  let(:fields) { %i[base_path content_id public_updated_at title publication_state] }

  let(:drug_safety_updates) { 10.times.map { |n| drug_safety_update_content_item(n) } }

  before do
    publishing_api_has_fields_for_document(described_class.publishing_api_document_type, drug_safety_updates, fields)

    drug_safety_updates.each do |drug_safety_update|
      publishing_api_has_item(drug_safety_update)
    end

    Timecop.freeze(Time.parse("2015-12-18 10:12:26 UTC"))
  end

  describe ".all" do
    it "returns all Drug Safety Updates" do
      expect(described_class.all.length).to be(drug_safety_updates.length)
    end
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
    before do
      email_alert_api_accepts_alert
    end

    it "publishes the Drug Safety Update" do
      stub_publishing_api_publish(drug_safety_updates[0]["content_id"], {})
      stub_any_rummager_post
      publishing_api_has_fields_for_document('organisation', [drug_safety_update_org_content_item], [:base_path, :content_id])

      drug_safety_update = described_class.find(drug_safety_updates[0]["content_id"])
      expect(drug_safety_update.publish!).to eq(true)

      assert_publishing_api_publish(drug_safety_update.content_id)
      assert_rummager_posted_item(indexable_attributes)
      assert_not_requested(:post, Plek.current.find('email-alert-api') + "/notifications")
    end
  end
end
