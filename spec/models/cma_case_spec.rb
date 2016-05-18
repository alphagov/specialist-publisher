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

  describe "#save! with attachments" do
    it "saves the CMA Case" do
      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links

      cma_case = cma_cases[1]

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

  describe "#find_attachment" do
    it "finds attachment object inside the document object" do
      document = described_class.find(cma_cases[1]["content_id"])
      attachment_content_id = document.attachments[0].content_id

      attachment = document.find_attachment(attachment_content_id)
      expect(attachment).to eq(document.attachments[0])
    end
  end
end
