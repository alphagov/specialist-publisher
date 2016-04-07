require 'spec_helper'

RSpec.describe CmaCase do
  def cma_case_content_item(n)
    Payloads.cma_case_content_item(
      "base_path" => "/cma-cases/example-cma-case-#{n}",
      "title" => "Example CMA Case #{n}",
      "description" => "This is the summary of example CMA case #{n}",
      "routes" => [
        {
          "path" => "/cma-cases/example-cma-case-#{n}",
          "type" => "exact",
        }
      ]
    )
  end

  let(:cma_org_content_item) {
    {
      "base_path" => "/government/organisations/competition-and-markets-authority",
      "content_id" => "957eb4ec-089b-4f71-ba2a-dc69ac8919ea",
      "title" => "Competition and Markets Authority",
      "format" => "placeholder_organisation",
      "need_ids" => [],
      "locale" => "en",
      "updated_at" => "2015-10-26T09:21:17.645Z",
      "public_updated_at" => "2015-03-10T16:23:14.000+00:00",
      "phase" => "live",
      "analytics_identifier" => "D550",
      "links" => {
        "available_translations" => [
          {
            "content_id" => "957eb4ec-089b-4f71-ba2a-dc69ac8919ea",
            "title" => "Competition and Markets Authority",
            "base_path" => "/government/organisations/competition-and-markets-authority",
            "description" => nil,
            "api_url" => "https://www.gov.uk/api/content/government/organisations/competition-and-markets-authority",
            "web_url" => "https://www.gov.uk/government/organisations/competition-and-markets-authority",
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
      "title" => "Example CMA Case 0",
      "description" => "This is the summary of example CMA case 0",
      "link" => "/cma-cases/example-cma-case-0",
      "indexable_content" => "## Header" + ("\r\n\r\nThis is the long body of an example CMA case" * 10),
      "public_timestamp" => "2015-12-03T16:59:13+00:00",
      "opened_date" => "2014-01-01",
      "closed_date" => nil,
      "case_type" => "ca98-and-civil-cartels",
      "case_state" => "open",
      "market_sector" => ["energy"],
      "outcome_type" => nil,
      "organisations" => ["competition-and-markets-authority"],
    }
  }

  let(:fields) { %i[base_path content_id public_updated_at title publication_state] }

  let(:cma_cases) { 10.times.map { |n| cma_case_content_item(n) } }

  let(:email_alert_payload) do
    {
      "links" => {
        "topics" => [cma_cases[0]["content_id"]]
      },
      "document_type" => "cma_case"
    }
  end

  before do
    publishing_api_has_fields_for_document(described_class.publishing_api_document_type, cma_cases, fields)

    cma_cases[1]["details"].merge!(
      "attachments" => [
        {
          "content_id" => "77f2d40e-3853-451f-9ca3-a747e8402e34",
          "url" => "https://assets.digital.cabinet-office.gov.uk/media/513a0efbed915d425e000002/asylum-support-image.jpg",
          "content_type" => "application/jpeg",
          "title" => "asylum report image title",
          "created_at" => "2015-12-18T10:12:26+00:00",
          "updated_at" => "2015-12-18T10:12:26+00:00"
        },
        {
          "content_id" => "ec3f6901-4156-4720-b4e5-f04c0b152141",
          "url" => "https://assets.digital.cabinet-office.gov.uk/media/513a0efbed915d425e000002/asylum-support-pdf.pdf",
          "content_type" => "application/pdf",
          "title" => "asylum report pdf title",
          "created_at" => "2015-12-18T10:12:26+00:00",
          "updated_at" => "2015-12-18T10:12:26+00:00"
        }
      ]
    )

    cma_cases.each do |cma_case|
      publishing_api_has_item(cma_case)
    end

    Timecop.freeze(Time.parse("2015-12-18 10:12:26 UTC"))
  end

  context ".all" do
    it "returns all CMA Cases" do
      expect(described_class.all.length).to be(cma_cases.length)
    end
  end

  context ".find" do
    it "returns a CMA Case" do
      content_id = cma_cases[0]["content_id"]
      cma_case = described_class.find(content_id)

      expect(cma_case.base_path).to     eq(cma_cases[0]["base_path"])
      expect(cma_case.title).to         eq(cma_cases[0]["title"])
      expect(cma_case.summary).to       eq(cma_cases[0]["description"])
      expect(cma_case.body).to          eq(cma_cases[0]["details"]["body"][0]["content"])
      expect(cma_case.opened_date).to   eq(cma_cases[0]["details"]["metadata"]["opened_date"])
      expect(cma_case.closed_date).to   eq(cma_cases[0]["details"]["metadata"]["closed_date"])
      expect(cma_case.case_type).to     eq(cma_cases[0]["details"]["metadata"]["case_type"])
      expect(cma_case.case_state).to    eq(cma_cases[0]["details"]["metadata"]["case_state"])
      expect(cma_case.market_sector).to eq(cma_cases[0]["details"]["metadata"]["market_sector"])
      expect(cma_case.outcome_type).to  eq(cma_cases[0]["details"]["metadata"]["outcome_type"])
    end
  end

  describe "#save! without attachments" do
    it "saves the CMA Case" do
      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links

      cma_case = cma_cases[0]

      cma_case.delete("publication_state")
      cma_case.merge!("public_updated_at" => "2015-12-18T10:12:26+00:00")
      cma_case["details"].merge!(
        "change_history" => [
          {
            "public_timestamp" => "2015-12-18T10:12:26+00:00",
            "note" => "First published.",
          }
        ]
      )

      c = described_class.find(cma_case["content_id"])
      expect(c.save!).to eq(true)

      assert_publishing_api_put_content(c.content_id, request_json_includes(cma_case))
      expect(cma_case.to_json).to be_valid_against_schema('specialist_document')
    end
  end

  describe "#save! with attachments" do
    it "saves the CMA Case" do
      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links

      cma_case = cma_cases[1]

      cma_case.delete("publication_state")
      cma_case.merge!("public_updated_at" => "2015-12-18T10:12:26+00:00")
      cma_case["details"].merge!(
        "change_history" => [
          {
            "public_timestamp" => "2015-12-18T10:12:26+00:00",
            "note" => "First published.",
          }
        ]
      )

      c = described_class.find(cma_case["content_id"])
      expect(c.save!).to eq(true)

      assert_publishing_api_put_content(c.content_id, request_json_includes(cma_case))
      expect(cma_case.to_json).to be_valid_against_schema('specialist_document')
    end
  end

  describe "#publish!" do
    before do
      email_alert_api_accepts_alert
    end

    it "publishes the CMA Case" do
      stub_publishing_api_publish(cma_cases[0]["content_id"], {})
      stub_any_rummager_post
      publishing_api_has_fields_for_document('organisation', [cma_org_content_item], [:base_path, :content_id])

      c = described_class.find(cma_cases[0]["content_id"])
      expect(c.publish!).to eq(true)

      assert_publishing_api_publish(c.content_id)
      assert_rummager_posted_item(indexable_attributes)
      assert_email_alert_sent(email_alert_payload)
    end
  end

  describe "#find_attachment" do
    it "finds attachment object inside the document object" do
      document = described_class.find(cma_cases[1]["content_id"])
      attachment_content_id = document.attachments[0].content_id

      attachment = document.find_attachment(attachment_content_id)
      expect(attachment).to eq(document.attachments[0])
    end
  end
end
