require 'spec_helper'

describe CmaCase do

  def cma_case_content_item(n)
    {
      "content_id" => SecureRandom.uuid,
      "base_path" => "/cma-cases/example-cma-case-#{n}",
      "title" => "Example CMA Case #{n}",
      "description" => "This is the summary of example CMA case #{n}",
      "format" => "specialist_document",
      "publishing_app" => "specialist-publisher",
      "rendering_app" => "specialist-frontend",
      "locale" => "en",
      "phase" => "live",
      "public_updated_at" => "2015-11-16T11:53:30",
      "publication_state" => "draft",
      "details" => {
        "body" => "## Header" + ("\r\n\r\nThis is the long body of an example CMA case" * 10),
        "metadata" => {
          "opened_date" => "2014-01-01",
          "case_type" => "ca98-and-civil-cartels",
          "case_state" => "open",
          "market_sector" => ["energy"],
          "document_type" => "cma_case",
        },
        "change_history" => [],
      },
      "routes" => [
        {
          "path" => "/cma-cases/example-cma-case-#{n}",
          "type" => "exact",
        }
      ],
      "redirects" => [],
      "update_type" => "major",
    }
  end

  let(:non_cma_case_content_item) {
    {
      "content_id" => SecureRandom.uuid,
      "format" => "specialist_document",
      "details" => {
        "metadata" => {
          "document_type" => "not_a_cma_case",
        },
      },
    }
  }

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
      "public_timestamp" => "2015-11-16T11:53:30+00:00",
      "opened_date" => "2014-01-01",
      "closed_date" => nil,
      "case_type" => "ca98-and-civil-cartels",
      "case_state" => "open",
      "market_sector" => ["energy"],
      "outcome_type" => nil,
      "organisations" => ["competition-and-markets-authority"],
    }
  }

  before do
    @fields = [
      :base_path,
      :content_id,
      :title,
      :public_updated_at,
      :details,
      :description,
    ]

    @cma_cases = []

    10.times do |n|
      @cma_cases << cma_case_content_item(n)
    end

    publishing_api_has_fields_for_format('specialist_document', @cma_cases, @fields)

    @cma_cases.each do |cma_case|
      publishing_api_has_item(cma_case)
    end

    Timecop.freeze(Time.parse("2015-12-18 10:12:26 UTC"))
  end

  context "#all" do
    it "returns all CMA Cases" do
      expect(described_class.all.length).to be(@cma_cases.length)
    end

    it "rejects any non CMA Cases" do
      all_specialist_documents = [non_cma_case_content_item] + @cma_cases
      publishing_api_has_fields_for_format('specialist_document', all_specialist_documents , @fields)
      publishing_api_has_item(non_cma_case_content_item)

      expect(described_class.all.length).to be(@cma_cases.length)
    end
  end

  context "#find" do
    it "returns a CMA Case" do
      content_id = @cma_cases[0]["content_id"]
      cma_case = described_class.find(content_id)

      expect(cma_case.base_path).to     eq(@cma_cases[0]["base_path"])
      expect(cma_case.title).to         eq(@cma_cases[0]["title"])
      expect(cma_case.summary).to       eq(@cma_cases[0]["description"])
      expect(cma_case.body).to          eq(@cma_cases[0]["details"]["body"])
      expect(cma_case.opened_date).to   eq(@cma_cases[0]["details"]["metadata"]["opened_date"])
      expect(cma_case.closed_date).to   eq(@cma_cases[0]["details"]["metadata"]["closed_date"])
      expect(cma_case.case_type).to     eq(@cma_cases[0]["details"]["metadata"]["case_type"])
      expect(cma_case.case_state).to    eq(@cma_cases[0]["details"]["metadata"]["case_state"])
      expect(cma_case.market_sector).to eq(@cma_cases[0]["details"]["metadata"]["market_sector"])
      expect(cma_case.outcome_type).to  eq(@cma_cases[0]["details"]["metadata"]["outcome_type"])
    end
  end

  context "#save!" do
    it "saves the CMA Case" do
      stub_any_publishing_api_put_content
      stub_any_publishing_api_put_links

      cma_case = @cma_cases[0]

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

      assert_publishing_api_put_content(c.content_id, request_json_including(cma_case))
      expect(cma_case.to_json).to be_valid_against_schema('specialist_document')
    end
  end

  context "#publish!" do
    it "publishes the CMA Case" do
      stub_publishing_api_publish(@cma_cases[0]["content_id"], {})
      stub_any_rummager_post
      publishing_api_has_fields_for_format('organisation', [cma_org_content_item], [:base_path, :content_id])

      c = described_class.find(@cma_cases[0]["content_id"])
      expect(c.publish!).to eq(true)

      assert_publishing_api_publish(c.content_id)
      assert_rummager_posted_item(indexable_attributes)
    end
  end
end
