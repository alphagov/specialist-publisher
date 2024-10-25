require "spec_helper"

RSpec.feature "Editing the CMA case finder", type: :feature do
  let(:organisations) do
    [
      { "content_id" => "957eb4ec-089b-4f71-ba2a-dc69ac8919ea", "title" => "Competition and Markets Authority" },
    ]
  end

  before do
    log_in_as_editor(:cma_editor)
    stub_publishing_api_has_content([], hash_including(document_type: CmaCase.document_type))
    stub_publishing_api_has_content(organisations, hash_including(document_type: Organisation.document_type))
  end

  scenario "changing all fields" do
    visit "admin/cma-cases"
    click_link "Request changes"

    expect(page).to have_selector("span", text: "CMA Case finder")
    expect(page).to have_selector("h1", text: "Request change: Finder details")

    fill_in "name", with: "Changed title"
    fill_in "base_path", with: "Changed slug"
    fill_in "description", with: "Changed description"
    fill_in "summary", with: "Changed summary"
    fill_in "Link 1", with: "Changed link 1"
    fill_in "Link 2", with: "Changed link 2"
    fill_in "Link 3", with: "Changed link 3"
    fill_in "document_noun", with: "Changed document noun"

    click_button "Submit changes"

    expect(page).to have_selector("dt", text: "Changed title")
    expect(page).to have_selector("dt", text: "Changed slug")
    expect(page).to have_selector("dt", text: "Changed description")
    expect(page).to have_selector("dt", text: "Changed summary")
    expect(page).to have_selector("dt", text: "Changed link 1")
    expect(page).to have_selector("dt", text: "Changed link 2")
    expect(page).to have_selector("dt", text: "Changed link 3")
    expect(page).to have_selector("dt", text: "Changed document noun")
  end

  scenario "fields are not shown on the confirmation page if not changed" do
    visit "admin/metadata/cma-cases"
    click_button "Submit changes"
    expect(page).not_to have_selector("dt")
  end

  scenario "unchecking 'Any related links on GOV.UK?' removes related links" do
    visit "admin/metadata/cma-cases"

    uncheck "include_related"

    click_button "Submit changes"

    expect(page.find(".govuk-summary-list__row", text: "Any related links on GOV.UK?")).to have_selector("dt", text: "No")
  end
end
