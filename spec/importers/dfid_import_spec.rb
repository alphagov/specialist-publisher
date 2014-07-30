require "spec_helper"
require "dfid_import"

require "features/support/panopticon_helpers"
require "webmock/rspec"
require "features/support/attachment_helpers"

RSpec.describe "DFID import" do
  include PanopticonHelpers
  include AttachmentHelpers

  before do
    stub_panopticon
    stub_asset_manager
  end

  def import
    DfidImport.call(data_dir)
  end

  let(:data_dir) { "./spec/fixtures/dfid_import" }

  let(:repo) {
    SpecialistPublisherWiring.get(:international_development_fund_repository)
  }
  let(:imported_report) {
    repo.all.last
  }

  context "with a successful import" do
    it "imports standard fields" do
      import

      expect(imported_report.title).not_to be_empty
      expect(imported_report.body).not_to be_empty
      expect(imported_report.summary).not_to be_blank
      expect(imported_report).to be_valid
    end

    it "attaches and replaces body text for assets" do
      import

      expect(imported_report.attachments).not_to be_empty
      expect(imported_report.body).not_to include("[InlineAttachment:1]")
      expect(imported_report.body).to include("[InlineAttachment:Attached-document.pdf]")
    end
  end
end
