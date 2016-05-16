require 'spec_helper'

RSpec.feature "Searching and filtering", type: :feature do
  let(:test_date) { Date.new(2016, 1, 11) }
  let(:cma_cases) {
    ten_example_cases = 10.times.collect do |n|
      Payloads.cma_case_content_item(
        "title" => "Example CMA Case #{n}",
        "description" => "This is the summary of example CMA case #{n}",
        "base_path" => "/cma-cases/example-cma-case-#{n}",
        "publication_state" => "draft",
        "updated_at" => (test_date - (n + 1).days).iso8601,
        "public_updated_at" => (test_date - (10 - n).days).iso8601,
      )
    end
    ten_example_cases[1]["publication_state"] = "live"
    ten_example_cases
  }

  before do
    log_in_as_editor(:cma_editor)
  end

  context "visiting the index with results" do
    before do
      publishing_api_has_content(cma_cases, hash_including(document_type: CmaCase.document_type))
    end

    scenario "viewing the unfiltered items" do
      visit "/cma-cases"

      expect(page.status_code).to eq(200)
      expect(page).to have_selector('li.document', count: 10)
      expect(page).to have_content("Example CMA Case 0")
      expect(page).to have_content("Example CMA Case 1")
      expect(page).to have_content("Example CMA Case 2")
    end

    scenario "viewing the publication state on the index page" do
      visit "/cma-cases"

      within(".document-list li.document:nth-child(2)") do
        expect(page).to have_css(".label-default")
        expect(page).to have_content("published")
      end

      within(".document-list li.document:nth-child(3)") do
        expect(page).to have_css(".label-primary")
        expect(page).to have_content("draft")
      end
    end

    scenario "viewing the updated_at field on the index page" do
      Timecop.freeze(test_date) do
        visit "/cma-cases"

        within(".document-list li.document:nth-child(1)") do
          expect(page).to have_content("Updated 1 day ago")
        end

        within(".document-list li.document:nth-child(10)") do
          expect(page).to have_content("Updated 10 days ago")
        end
      end
    end

    scenario "filtering the items with some results returned" do
      publishing_api_has_content([cma_cases.first], hash_including(document_type: CmaCase.document_type, q: "0"))

      visit "/cma-cases"

      fill_in "Search", with: "0"
      click_button "Search"
      expect(page).to have_content("Example CMA Case 0")
      expect(page).to have_selector('li.document', count: 1)
    end

    scenario "filtering the items with no results returned" do
      publishing_api_has_content([], hash_including(document_type: CmaCase.document_type, q: "abcdef"))

      visit "/cma-cases"
      fill_in "Search", with: "abcdef"
      click_button "Search"
      expect(page).to have_content("Your search – abcdef – did not match any documents.")
    end
  end

  context "visiting the index with no results" do
    before do
      publishing_api_has_content([], hash_including(document_type: CmaCase.document_type))
    end

    scenario "viewing the unfiltered items" do
      visit "/cma-cases"

      expect(page.status_code).to eq(200)
      expect(page).to have_content("No CMA Cases available.")
    end
  end
end
