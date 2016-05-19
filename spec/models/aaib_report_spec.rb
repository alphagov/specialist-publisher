require 'spec_helper'

RSpec.describe AaibReport do
  def aaib_report_content_item(n)
    FactoryGirl.create(:aaib_report,
      base_path: "/aaib-reports/example-aaib-report-#{n}",
      title: "Example AAIB Report #{n}",
      description: "This is the summary of example AAIB Report #{n}")
  end

  let(:indexable_attributes) {
    {
      "title" => "Example AAIB Report 0",
      "description" => "This is the summary of example AAIB Report 0",
      "link" => "/aaib-reports/example-aaib-report-0",
      "indexable_content" => "Header " + (["This is the long body of an example document"] * 10).join(" "),
      "public_timestamp" => "2015-11-16T11:53:30+00:00",
      "date_of_occurrence" => "2015-10-10",
    }
  }

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

      c = described_class.find(aaib_report["content_id"])
      expect(c.save!).to eq(true)

      expected_payload = write_payload(aaib_report).deep_merge(
        "public_updated_at" => "2015-12-18T10:12:26+00:00",
        "details" => {
          "change_history" => [
            {
              "public_timestamp" => "2015-12-18T10:12:26+00:00",
              "note" => "First published.",
            }
          ]
        }
      )

      assert_publishing_api_put_content(c.content_id, expected_payload)
      expect(expected_payload.to_json).to be_valid_against_schema('specialist_document')
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
