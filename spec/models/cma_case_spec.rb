require 'spec_helper'

describe CmaCase do

  def cma_case_content_item(n)
    {
      "content_id" => SecureRandom.uuid,
      "base_path" => "/cma-cases/example-cma-case-#{n}",
      "title" => "Example CMA Case #{n}",
      "description" => "This is the summary of example CMA case #{n}",
      "format" => "cma_case",
      "publishing_app" => "specialist-publisher",
      "rendering_app" => "specialist-frontend",
      "locale" => "en",
      "phase" => "live",
      "public_updated_at" => "2015-11-16T11:53:30.000+00:00",
      "details" => {
        "body" => "## Header" + ("\r\n\r\nThis is the long body of an example CMA case" * 10),
        "metadata" => {
          "opened_date" => "2014-01-01",
          "closed_date" => "",
          "case_type" => "ca98-and-civil-cartels",
          "case_state" => "open",
          "market_sector" => ["energy"],
          "outcome_type" => "",
          "document_type" => "cma_case",
        }
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

  before do
    fields = [
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

    publishing_api_has_fields_for_format('cma_case', @cma_cases, fields)

    publishing_api_has_item(@cma_cases[0])

    Timecop.freeze(Time.parse("2015-12-18 10:12:26 UTC"))
  end

  context "#all" do
    it "returns all CMA Cases" do
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

      @cma_cases[0].merge!("public_updated_at" => "2015-12-18 10:12:26 UTC")

      c = described_class.find(@cma_cases[0]["content_id"])
      expect(c.save!).to eq(true)

      assert_publishing_api_put_content(c.content_id, request_json_including(@cma_cases[0]))
    end
  end
end
