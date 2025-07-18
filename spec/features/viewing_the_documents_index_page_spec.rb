require "spec_helper"

RSpec.feature "Viewing the document index page", type: :feature do
  before do
    log_in_as_editor(:cma_editor)
  end

  scenario "visiting the index of a live finder has a link to 'view on website'" do
    stub_publishing_api_has_content([], hash_including(document_type: CmaCase.document_type))

    visit "/cma-cases"

    expect(page).to have_link("View on website (opens in new tab)", href: "http://www.dev.gov.uk/cma-cases")
  end

  scenario "visiting the index of a draft finder has a link to 'preview draft'" do
    stub_publishing_api_has_content([], hash_including(document_type: CmaCase.document_type))

    allow(CmaCase).to receive(:target_stack).and_return("draft")

    visit "/cma-cases"

    expect(page).to have_link("Preview draft (opens in new tab)", href: "http://draft-origin.dev.gov.uk/cma-cases")
  end
end
