require "spec_helper"

RSpec.feature "Access control", type: :feature do
  before do
    stub_publishing_api_has_content([], hash_including(document_type: SpecialistDocument::CmaCase.document_type))
    stub_publishing_api_has_content([], hash_including(document_type: SpecialistDocument::AaibReport.document_type))
    stub_publishing_api_has_content([], hash_including(document_type: SpecialistDocument::StatutoryInstrument.document_type))
  end

  context "as a CMA Editor" do
    before do
      log_in_as_editor(:cma_editor)
    end

    scenario "visiting /cma-cases" do
      visit "/cma-cases"

      expect(page.status_code).to eq(200)
      expect(page).to have_content("CMA Cases")
    end

    scenario "visiting /aaib-reports" do
      visit "/aaib-reports"

      expect(page.current_path).to eq("/cma-cases")
      expect(page).to have_content("You aren't permitted to access AAIB Reports")
    end

    scenario "visiting a format which doesn't exist" do
      visit "/a-format-which-doesnt-exist"

      expect(page.current_path).to eq("/cma-cases")
      expect(page).to have_content("That format doesn't exist.")
    end
  end

  context "as an AAIB Editor" do
    before do
      log_in_as_editor(:aaib_editor)
    end

    scenario "visiting /aaib-reports" do
      visit "/aaib-reports"

      expect(page.status_code).to eq(200)
      expect(page).to have_content("AAIB Reports")
    end

    scenario "visiting /cma-cases" do
      visit "/cma-cases"

      expect(page.current_path).to eq("/aaib-reports")
      expect(page).to have_content("You aren't permitted to access CMA Cases")
    end
  end

  context "as a statutory instrument editor" do
    before do
      stub_publishing_api_has_content([], hash_including(document_type: Organisation.document_type))
      log_in_as_editor(:statutory_instrument_editor)
    end

    scenario "visiting the statutory instruments format" do
      visit "/eu-withdrawal-act-2018-statutory-instruments"

      expect(page.status_code).to eq(200)
      expect(page).to have_content("EU Withdrawal Act 2018 statutory instruments")
    end

    scenario "visiting another format" do
      visit "/cma-cases"

      expect(page.current_path).to eq("/eu-withdrawal-act-2018-statutory-instruments")
      expect(page).to have_content("You aren't permitted to access CMA Cases")
    end

    scenario "visiting the home page" do
      visit "/"

      expect(page.current_path).to eq("/eu-withdrawal-act-2018-statutory-instruments")
    end
  end

  context "as an editor with incorrect organisation_content_id" do
    before do
      log_in_as_editor(:incorrect_id_editor)
    end

    scenario "visiting /" do
      visit "/"

      expect(page.status_code).to eq(200)
      expect(page).to have_content("Sorry, you don't have permission to access this application")
      expect(page).to have_content("Please contact your main GDS contact if you need access.")
    end
  end
end
