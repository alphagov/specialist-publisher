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

  let(:cma_cases) { 10.times.map { |n| cma_case_content_item(n) } }

  before do
    cma_cases.each do |cma_case|
      publishing_api_has_item(cma_case)
    end

    Timecop.freeze(Time.parse("2015-12-18 10:12:26 UTC"))
  end

  describe "#save! without attachments" do
    it "saves the CMA Case" do
      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links

      cma_case = cma_cases[0]

      cma_case.delete("publication_state")
      cma_case.delete("updated_at")
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
end
