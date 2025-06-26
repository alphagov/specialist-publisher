require "spec_helper"

RSpec.feature "Creating a UKHSA Data Access Approval", type: :feature do
  before do
    log_in_as_editor(:gds_editor)
  end

  scenario "it populates the body textarea with the 'body_template' value" do
    visit "/ukhsa-data-access-approvals/new"
    expect(page.current_path).to eq("/ukhsa-data-access-approvals/new")
    expect(page).to have_content(UkhsaDataAccessApproval.finder_schema.body_template.truncate_words(5, omission: ""))
  end
end
