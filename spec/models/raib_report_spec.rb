require 'spec_helper'

RSpec.describe RaibReport do
  def raib_report_content_item(n)
    Payloads.raib_report_content_item(
      "base_path" => "/raib-reports/example-raib-report-#{n}",
      "title" => "Example RAIB Report #{n}",
      "description" => "This is the summary of example RAIB Report #{n}",
      "routes" => [
        {
          "path" => "/raib-reports/example-raib-report-#{n}",
          "type" => "exact",
        }
      ]
    )
  end

  let(:raib_reports) { 10.times.map { |n| raib_report_content_item(n) } }

  before do
    raib_reports.each do |raib_report|
      publishing_api_has_item(raib_report)
    end

    Timecop.freeze(Time.parse("2015-12-18 10:12:26 UTC"))
  end

  context ".find" do
    it "returns a AAIB Report" do
      content_id = raib_reports[0]["content_id"]
      raib_report = described_class.find(content_id)

      expect(raib_report.base_path).to            eq(raib_reports[0]["base_path"])
      expect(raib_report.title).to                eq(raib_reports[0]["title"])
      expect(raib_report.summary).to              eq(raib_reports[0]["description"])
      expect(raib_report.body).to                 eq(raib_reports[0]["details"]["body"][0]["content"])
      expect(raib_report.date_of_occurrence).to   eq(raib_reports[0]["details"]["metadata"]["date_of_occurrence"])
    end
  end

  describe "#save!" do
    it "saves the RAIB Report" do
      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links

      raib_report = raib_reports[0]

      raib_report.delete("publication_state")
      raib_report.delete("updated_at")
      raib_report.merge!("public_updated_at" => "2015-12-18T10:12:26+00:00")
      raib_report["details"].merge!(
        "change_history" => [
          {
            "public_timestamp" => "2015-12-18T10:12:26+00:00",
            "note" => "First published.",
          }
        ]
      )

      c = described_class.find(raib_report["content_id"])
      expect(c.save!).to eq(true)

      assert_publishing_api_put_content(c.content_id, request_json_includes(raib_report))
      expect(raib_report.to_json).to be_valid_against_schema('specialist_document')
    end
  end
end
