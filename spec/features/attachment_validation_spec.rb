require "spec_helper"

RSpec.feature "Validating inline attachments", type: :feature do
  before do
    log_in_as_editor(:cma_editor)
  end

  scenario "creating a document that references attachments that don't exist" do
    visit "/cma-cases/new"
    fill_in "Body", with: "[InlineAttachment:missing.pdf]"
    click_button "Save"

    expect(page).to have_content("Please fix the following errors")
    expect(page).to have_content(
      "Body contains an attachment that can't be found: 'missing.pdf'"
    )
  end
end
