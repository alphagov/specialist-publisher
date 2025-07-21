require "spec_helper"

RSpec.feature "Filtering documents by title", type: :feature do
  let(:documents) { 3.times.map { |index| FactoryBot.create(:cma_case, title: "Example CMA Case #{index}") } }

  before do
    log_in_as_editor(:cma_editor)
    stub_publishing_api_has_content(documents, hash_including(document_type: CmaCase.document_type))
  end

  context "filtering by title" do
    scenario "filtering the items with some results returned" do
      stub_publishing_api_has_content([documents.first], hash_including(document_type: CmaCase.document_type, q: "0"))

      visit "/cma-cases"

      expect(page).not_to have_select("Organisation")

      fill_in "Title", with: "0"
      click_button "Filter"
      expect(page).to have_content("Example CMA Case 0")
      expect(page).to have_selector("#document-index-section table tbody tr", count: 1)
    end

    scenario "filtering the items with no results returned" do
      stub_publishing_api_has_content([], hash_including(document_type: CmaCase.document_type, q: "abcdef"))

      visit "/cma-cases"
      fill_in "Title", with: "abcdef"
      click_button "Filter"
      expect(page).to have_content("Your filter – abcdef – did not match any documents.")
    end
  end

  context "pagination" do
    let(:per_page) { 2 }

    before do
      cma_cases = 3.times.map do |index|
        FactoryBot.create(:cma_case,
                          title: "Example cma case match string #{index}")
      end
      publishing_api_paginates_content(cma_cases, per_page, CmaCase, search_query: "match string")
    end

    scenario "navigating to the next page preserves the title query value" do
      visit "/cma-cases"

      fill_in "Title", with: "match string"
      click_button "Filter"

      expect(page.status_code).to eq(200)
      expect(page).to have_selector("#document-index-section table tbody tr", count: per_page)
      expect(page).to have_selector('[href="/cma-cases?page=2&query=match+string"]')
    end
  end
end
