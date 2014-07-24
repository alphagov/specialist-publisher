require "spec_helper"
require "aaib_import"

require "features/support/panopticon_helpers"
require "webmock/rspec" # required for attachment_helpers
require "features/support/attachment_helpers"

RSpec.describe "AAIB import" do
  include PanopticonHelpers
  include AttachmentHelpers

  before do
    stub_out_panopticon
    stub_asset_manager
  end

  def import
    AaibImport.call(data_dir, attachments_dir)
  end

  let(:data_dir)            { "spec/fixtures/import/metadata" }
  let(:attachments_dir)     { "spec/fixtures/import/" }

  let(:report_title) { "2/1981 Cessna 414, G-BAOZ" }

  let(:expected_extra_fields) {
    {
      registration_string: "G-BAOZ",
      date_of_occurrence: "1980-03-23",
      registration: ["G-BAOZ"],
      aircraft_category: ["commercial-fixed-wing"],
      report_type: "formal-report",
      location: "Near Leeds Bradford Airport",
      aircraft_type: "Cessna 414",
    }
  }

  let(:repo) {
    SpecialistPublisherWiring.get(:aaib_report_repository)
  }
  let(:imported_report) {
    repo.all.last
  }

  context "with a successful import" do
    it "imports standard fields" do
      import

      expect(imported_report.title).not_to be_empty
      expect(imported_report.body).not_to be_empty
      expect(imported_report.summary).to be_blank
      expect(imported_report).not_to be_valid
      expect(imported_report.errors.keys).to eq([:summary])
    end

    it "imports extra fields" do
      import

      expect(imported_report.extra_fields).to eq(expected_extra_fields)
    end

    it "attaches and replaces body text for assets" do
      import

      expect(imported_report.attachments).not_to be_empty
      expect(imported_report.body).not_to include("[ASSET_TAG]")
    end
  end
end
