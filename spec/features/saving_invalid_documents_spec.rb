require "spec_helper"

RSpec.describe "Saving invalid documents", type: :feature do
  before do
    login_as(:aaib_editor)
    stub_organisation_details(GDS::SSO.test_user.organisation_slug)
  end

  context "with a published AAIB report" do
    before do
      create_aaib_report title: "A title", summary: "A summary", body: "A body", date_of_occurrence: "2015-01-01"
    end

    it "lists the report" do
      check_for_new_aaib_report_title "A title"
    end
  end
end
