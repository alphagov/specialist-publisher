require "spec_helper"

RSpec.feature "Visiting the app", type: :feature do
  before do
    log_in_as_editor(:cma_editor)
    stub_publishing_api_has_content([], hash_including(document_type: SpecialistDocument::CmaCase.document_type))
  end

  scenario "visiting / should display /cma-cases" do
    visit "/"
    expect(page).to have_selector("h1", text: "CMA Cases")
    expect(page).to have_selector("nav a", text: "CMA Cases")
    expect(page).not_to have_content("AAIB Reports")
    expect(page).not_to have_content("Manuals")
  end

  scenario "visiting any path should set an authenticated user header" do
    visit "/"
    expect(/uid-\d+/).to match(GdsApi::GovukHeaders.headers[:x_govuk_authenticated_user])
  end
end
