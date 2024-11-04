require "spec_helper"

RSpec.feature "Editing the Farming grant finder", type: :feature do
  let(:organisations) do
    [
      { "content_id" => "de4e9dc6-cca4-43af-a594-682023b84d6c", "title" => "Department for Environment, Food & Rural Affairs" },
      { "content_id" => "e8fae147-6232-4163-a3f1-1c15b755a8a4", "title" => "Rural Payments Agency" },
    ]
  end

  before do
    log_in_as_editor(:farming_grant_editor)
    stub_publishing_api_has_content([], hash_including(document_type: FarmingGrant.document_type))
    stub_publishing_api_has_content(organisations, hash_including(document_type: Organisation.document_type))
  end

  scenario "fields are not shown on the confirmation page if not changed" do
    visit "admin/metadata/farming-grants"
    click_button "Submit changes"
    expect(page).not_to have_selector("dt")
  end
end
