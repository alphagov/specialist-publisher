require 'spec_helper'

describe RaibReport do
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

  let(:indexable_attributes) {
    {
      "title" => "Example RAIB Report 0",
      "description" => "This is the summary of example RAIB Report 0",
      "link" => "/raib-reports/example-raib-report-0",
      "indexable_content" => "## Header" + ("\r\n\r\nThis is the long body of an example RAIB Report" * 10),
      "public_timestamp" => "2015-11-16T11:53:30+00:00",
      "date_of_occurrence" => "2015-10-10",
    }
  }

  let(:fields) { %i[base_path content_id public_updated_at title publication_state] }
  let(:raib_reports) { 10.times.map { |n| raib_report_content_item(n) } }
  let(:page) { 1 }
  let(:per_page) { 50 }

  before do
    publishing_api_has_content(raib_reports, hash_including(document_type: described_class.publishing_api_document_type))

    raib_reports.each do |raib_report|
      publishing_api_has_item(raib_report)
    end

    Timecop.freeze(Time.parse("2015-12-18 10:12:26 UTC"))
  end

  context ".all" do
    it "returns all RAIB Reports" do
      expect(described_class.all(page, per_page).results.length).to be(raib_reports.length)
    end
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

  describe "#publish!" do
    before do
      email_alert_api_accepts_alert
    end

    it "publishes the RAIB Report" do
      stub_publishing_api_publish(raib_reports[0]["content_id"], {})
      stub_any_rummager_post_with_queueing_enabled

      raib_report = described_class.find(raib_reports[0]["content_id"])
      expect(raib_report.publish!).to eq(true)

      assert_publishing_api_publish(raib_report.content_id)
      assert_rummager_posted_item(indexable_attributes)
    end
  end
end
