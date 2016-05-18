require 'spec_helper'

RSpec.describe AaibReport do
  def aaib_report_content_item(n)
    Payloads.aaib_report_content_item(
      "base_path" => "/aaib-reports/example-aaib-report-#{n}",
      "title" => "Example AAIB Report #{n}",
      "description" => "This is the summary of example AAIB Report #{n}",
      "routes" => [
        {
          "path" => "/aaib-reports/example-aaib-report-#{n}",
          "type" => "exact",
        }
      ]
    )
  end

  let(:aaib_reports) { 10.times.map { |n| aaib_report_content_item(n) } }

  before do
    aaib_reports.each do |aaib_report|
      publishing_api_has_item(aaib_report)
    end

    Timecop.freeze(Time.parse("2015-12-18 10:12:26 UTC"))
  end

  describe ".find" do
    it "returns a AAIB Report" do
      content_id = aaib_reports[0]["content_id"]
      aaib_report = described_class.find(content_id)

      expect(aaib_report.base_path).to            eq(aaib_reports[0]["base_path"])
      expect(aaib_report.title).to                eq(aaib_reports[0]["title"])
      expect(aaib_report.summary).to              eq(aaib_reports[0]["description"])
      expect(aaib_report.body).to                 eq(aaib_reports[0]["details"]["body"][0]["content"])
      expect(aaib_report.date_of_occurrence).to   eq(aaib_reports[0]["details"]["metadata"]["date_of_occurrence"])
    end
  end

  describe "#save!" do
    it "saves the AAIB Report" do
      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links

      aaib_report = aaib_reports[0]

      aaib_report.delete("publication_state")
      aaib_report.delete("updated_at")
      aaib_report.merge!("public_updated_at" => "2015-12-18T10:12:26+00:00")
      aaib_report["details"].merge!(
        "change_history" => [
          {
            "public_timestamp" => "2015-12-18T10:12:26+00:00",
            "note" => "First published.",
          }
        ]
      )

      c = described_class.find(aaib_report["content_id"])
      expect(c.save!).to eq(true)

      assert_publishing_api_put_content(c.content_id, request_json_includes(aaib_report))
      expect(aaib_report.to_json).to be_valid_against_schema('specialist_document')
    end
  end
end
