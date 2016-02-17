require 'spec_helper'

describe MaibReport do

  def maib_report_content_item(n)
    {
      "content_id" => SecureRandom.uuid,
      "base_path" => "/maib-reports/example-maib-report-#{n}",
      "title" => "Example MAIB Report #{n}",
      "description" => "This is the summary of example MAIB Report #{n}",
      "format" => "specialist_document",
      "publishing_app" => "specialist-publisher",
      "rendering_app" => "specialist-frontend",
      "locale" => "en",
      "phase" => "live",
      "public_updated_at" => "2015-11-16T11:53:30",
      "publication_state" => "draft",
      "details" => {
        "body" => "## Header" + ("\r\n\r\nThis is the long body of an example MAIB Report" * 10),
        "metadata" => {
          "date_of_occurrence" => "2015-10-10",
          "document_type" => "maib_report"
        },
      },
      "routes" => [
        {
          "path" => "/maib-reports/example-maib-report-#{n}",
          "type" => "exact",
        }
      ],
      "redirects" => [],
      "update_type" => "major",
    }
  end

  let(:non_maib_report_content_item) {
    {
      "content_id" => SecureRandom.uuid,
      "base_path" => "/other-reports/not-a-maib-report",
      "format" => "specialist_document",
      "details" => {
        "metadata" => {
          "document_type" => "not_an_maib_report",
        },
      },
    }
  }

  let(:maib_org_content_item) {
    {
      "base_path" => "/government/organisations/marine-accident-investigation-branch",
      "content_id" => "9c66b9a3-1e6a-48e8-974d-2a5635f84679",
      "title" => "Marine Accident Investigation Branch",
      "format" => "redirect",
      "need_ids" => [],
      "locale" => "en",
      "updated_at" => "2015-10-27T11:47:43.454Z",
      "public_updated_at" => "2014-12-19T14:16:32.000+00:00",
      "phase" => "live",
      "analytics_identifier" => nil,
      "links" => {
        "available_translations" => [
          {
            "content_id" => "9c66b9a3-1e6a-48e8-974d-2a5635f84679",
            "title" => "Marine Accident Investigation Branch",
            "base_path" => "/government/organisations/marine-accident-investigation-branch",
            "description" => "nil",
            "api_url" => "https://www.gov.uk/api/content/government/organisations/marine-accident-investigation-branch",
            "web_url" => "https://www.gov.uk/government/organisations/marine-accident-investigation-branch",
            "locale" => "en"
          }
        ]
      },
      "description" => nil,
      "details" => {
      }
    }
  }

  let(:indexable_attributes) {
    {
      "title" => "Example MAIB Report 0",
      "description" => "This is the summary of example MAIB Report 0",
      "link" => "/maib-reports/example-maib-report-0",
      "indexable_content" => "## Header" + ("\r\n\r\nThis is the long body of an example MAIB Report" * 10),
      "public_timestamp" => "2015-11-16T11:53:30+00:00",
      "date_of_occurrence" => "2015-10-10",
      "organisations" => ["marine-accident-investigation-branch"],
    }
  }

  before do
    @fields = [
      :base_path,
      :content_id,
    ]

    @maib_reports = []

    10.times do |n|
      @maib_reports << maib_report_content_item(n)
    end

    publishing_api_has_fields_for_format('specialist_document', @maib_reports, @fields)

    @maib_reports.each do |maib_report|
      publishing_api_has_item(maib_report)
    end

    Timecop.freeze(Time.parse("2015-12-18 10:12:26 UTC"))
  end

  context ".all" do
    it "returns all MAIB Reports" do
      expect(described_class.all.length).to be(@maib_reports.length)
    end

    it "rejects any non MAIB Reports" do
      all_specialist_documents = [non_maib_report_content_item] + @maib_reports
      publishing_api_has_fields_for_format('specialist_document', all_specialist_documents , @fields)
      publishing_api_has_item(non_maib_report_content_item)

      expect(described_class.all.length).to be(@maib_reports.length)
    end
  end

  context ".find" do
    it "returns a MAIB Report" do
      content_id = @maib_reports[0]["content_id"]
      maib_report = described_class.find(content_id)

      expect(maib_report.base_path).to            eq(@maib_reports[0]["base_path"])
      expect(maib_report.title).to                eq(@maib_reports[0]["title"])
      expect(maib_report.summary).to              eq(@maib_reports[0]["description"])
      expect(maib_report.body).to                 eq(@maib_reports[0]["details"]["body"])
      expect(maib_report.date_of_occurrence).to   eq(@maib_reports[0]["details"]["metadata"]["date_of_occurrence"])
    end
  end

  context "#save!" do
    it "saves the MAIB Report" do
      stub_any_publishing_api_put_content
      stub_any_publishing_api_put_links

      maib_report = @maib_reports[0]

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

  context "#publish!" do
    it "publishes the MAIB Report" do
      stub_publishing_api_publish(@maib_reports[0]["content_id"], {})
      stub_any_rummager_post
      publishing_api_has_fields_for_format('organisation', [maib_org_content_item], [:base_path, :content_id])

      maib_report = described_class.find(@maib_reports[0]["content_id"])
      expect(maib_report.publish!).to eq(true)

      assert_publishing_api_publish(maib_report.content_id)
      assert_rummager_posted_item(indexable_attributes)
    end
  end
end
