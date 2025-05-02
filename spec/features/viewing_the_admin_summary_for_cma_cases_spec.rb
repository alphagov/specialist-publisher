require "spec_helper"

RSpec.feature "Viewing the admin summary for CMA cases", type: :feature do
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

  scenario "viewing finders/cma-cases should display details of the CMA Case finder" do
    visit "finders/cma-cases"
    expect(page).to have_selector("h1", text: "CMA Case finder")
    expect(page).to have_selector("dt", text: "This case finder includes cases and projects from the Competition and Markets Authority (CMA), Office for the Internal Market (OIM) and Subsidy Advice Unit (SAU)")
    expect(page).to have_selector(".govspeak", text: "This case finder includes cases and projects from the Competition and Markets Authority (CMA), Office for the Internal Market (OIM) and Subsidy Advice Unit (SAU)")
    expect(page.find(".govuk-summary-list__row", text: "Should summary of each content show under the title in the finder list page?")).to have_selector("dt", text: "No")
    expect(page.find(".govuk-summary-list__row", text: "Organisations the finder should be attached to")).to have_selector("dt", text: "Competition and Markets Authority")
    expect(page.find(".govuk-summary-list__row", text: "Shortened document noun (How the documents on the finder are referred to)")).to have_selector("dt", text: "Case")
  end
end
