require 'spec_helper'

describe AaibReport do
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

  let(:indexable_attributes) {
    {
      "title" => "Example AAIB Report 0",
      "description" => "This is the summary of example AAIB Report 0",
      "link" => "/aaib-reports/example-aaib-report-0",
      "indexable_content" => "## Header" + ("\r\n\r\nThis is the long body of an example AAIB Report" * 10),
      "public_timestamp" => "2015-11-16T11:53:30+00:00",
      "date_of_occurrence" => "2015-10-10",
    }
  }

  let(:fields) { %i[base_path content_id public_updated_at title publication_state] }
  let(:aaib_reports) { 10.times.map { |n| aaib_report_content_item(n) } }
  let(:page) { 1 }
  let(:per_page) { 50 }

  before do
    publishing_api_has_content(aaib_reports, document_type: described_class.publishing_api_document_type, fields: fields, page: page, per_page: per_page)

    aaib_reports.each do |aaib_report|
      publishing_api_has_item(aaib_report)
    end

    Timecop.freeze(Time.parse("2015-12-18 10:12:26 UTC"))
  end

  describe ".all" do
    it "returns all AAIB Reports" do
      expect(described_class.all(page, per_page).results.length).to be(aaib_reports.length)
    end

    it "returns AAIB with necessary info" do
      sample_aaib_report = described_class.all(1, 50).results.sample
      expect(sample_aaib_report.base_path.nil?).to eq(false)
      expect(sample_aaib_report.content_id.nil?).to eq(false)
      expect(sample_aaib_report.title.nil?).to eq(false)
      expect(sample_aaib_report.publication_state.nil?).to eq(false)
      expect(sample_aaib_report.public_updated_at.nil?).to eq(false)
    end
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

  describe "#publish!" do
    before do
      email_alert_api_accepts_alert
    end

    let(:aaib_report) { described_class.find(aaib_reports[0]["content_id"]) }

    it "publishes the AAIB Report" do
      stub_publishing_api_publish(aaib_reports[0]["content_id"], {})
      stub_any_rummager_post_with_queueing_enabled
      expect(aaib_report.publish!).to eq(true)

      assert_publishing_api_publish(aaib_report.content_id)
      assert_rummager_posted_item(indexable_attributes)
    end

    it "notifies Airbrake and returns false if publishing-api does not return status 200" do
      expect(Airbrake).to receive(:notify)
      stub_publishing_api_publish(aaib_reports[0]["content_id"], {}, status: 503)
      stub_any_rummager_post_with_queueing_enabled
      expect(aaib_report.publish!).to eq(false)
    end

    it "notifies Airbrake and returns false if rummager does not return status 200" do
      expect(Airbrake).to receive(:notify)
      stub_publishing_api_publish(aaib_reports[0]["content_id"], {})
      stub_request(:post, %r{#{Plek.new.find('search')}/documents}).to_return(status: 503)
      expect(aaib_report.publish!).to eq(false)
    end
  end
end
