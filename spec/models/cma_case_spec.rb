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
  end

  context "#all" do
    it "returns all CMA Cases" do
      expect(described_class.all.length).to be(@cma_cases.length)
    end
  end
end
