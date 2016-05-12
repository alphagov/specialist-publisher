require 'spec_helper'

describe MaibReport do
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

  let(:indexable_attributes) {
    {
      "title" => "Example MAIB Report 0",
      "description" => "This is the summary of example MAIB Report 0",
      "link" => "/maib-reports/example-maib-report-0",
      "indexable_content" => "## Header" + ("\r\n\r\nThis is the long body of an example MAIB Report" * 10),
      "public_timestamp" => "2015-11-16T11:53:30+00:00",
      "date_of_occurrence" => "2015-10-10",
    }
  }

  let(:fields) { %i[base_path content_id public_updated_at title publication_state] }
  let(:maib_reports) { 10.times.map { |n| maib_report_content_item(n) } }
  let(:page) { 1 }
  let(:per_page) { 50 }

  before do
    publishing_api_has_content(maib_reports, hash_including(document_type: described_class.publishing_api_document_type))

    maib_reports.each do |maib_report|
      publishing_api_has_item(maib_report)
    end

    Timecop.freeze(Time.parse("2015-12-18 10:12:26 UTC"))
  end

  context ".all" do
    it "returns all MAIB Reports" do
      expect(described_class.all(page, per_page).results.length).to be(maib_reports.length)
    end
  end

  context ".find" do
    it "returns a MAIB Report" do
      content_id = maib_reports[0]["content_id"]
      maib_report = described_class.find(content_id)

      expect(maib_report.base_path).to            eq(maib_reports[0]["base_path"])
      expect(maib_report.title).to                eq(maib_reports[0]["title"])
      expect(maib_report.summary).to              eq(maib_reports[0]["description"])
      expect(maib_report.body).to                 eq(maib_reports[0]["details"]["body"][0]["content"])
      expect(maib_report.date_of_occurrence).to   eq(maib_reports[0]["details"]["metadata"]["date_of_occurrence"])
    end
  end

  describe "#save!" do
    it "saves the MAIB Report" do
      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links

      maib_report = maib_reports[0]

      maib_report.delete("publication_state")
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

  describe "#publish!" do
    before do
      email_alert_api_accepts_alert
    end

    it "publishes the MAIB Report" do
      stub_publishing_api_publish(maib_reports[0]["content_id"], {})
      stub_any_rummager_post_with_queueing_enabled

      maib_report = described_class.find(maib_reports[0]["content_id"])
      expect(maib_report.publish!).to eq(true)

      assert_publishing_api_publish(maib_report.content_id)
      assert_rummager_posted_item(indexable_attributes)
    end
  end
end
