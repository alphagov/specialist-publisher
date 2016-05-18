require 'spec_helper'

RSpec.describe MaibReport do
  def maib_report_content_item(n)
    Payloads.maib_report_content_item(
      "base_path" => "/maib-reports/example-maib-report-#{n}",
      "title" => "Example MAIB Report #{n}",
      "description" => "This is the summary of example MAIB Report #{n}",
      "routes" => [
        {
          "path" => "/maib-reports/example-maib-report-#{n}",
          "type" => "exact",
        }
      ]
    )
  end

  let(:maib_reports) { 10.times.map { |n| maib_report_content_item(n) } }

  before do
    maib_reports.each do |maib_report|
      publishing_api_has_item(maib_report)
    end

    Timecop.freeze(Time.parse("2015-12-18 10:12:26 UTC"))
  end

  describe "#save!" do
    it "saves the MAIB Report" do
      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links

      maib_report = maib_reports[0]

      maib_report.delete("publication_state")
      maib_report.delete("updated_at")
      maib_report.merge!("public_updated_at" => "2015-12-18T10:12:26+00:00")
      maib_report["details"].merge!(
        "change_history" => [
          {
            "public_timestamp" => "2015-12-18T10:12:26+00:00",
            "note" => "First published.",
          }
        ]
      )

      c = described_class.find(maib_report["content_id"])
      expect(c.save!).to eq(true)

      assert_publishing_api_put_content(c.content_id, request_json_includes(maib_report))
      expect(maib_report.to_json).to be_valid_against_schema('specialist_document')
    end
  end
end
