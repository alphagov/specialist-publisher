require 'spec_helper'

RSpec.feature "Access control", type: :feature do
  let(:fields) { [:base_path, :content_id, :public_updated_at, :title, :publication_state] }

  before do
    publishing_api_has_fields_for_document(CmaCase.publishing_api_document_type, [], fields)
    publishing_api_has_fields_for_document(AaibReport.publishing_api_document_type, [], fields)
    publishing_api_has_fields_for_document('manual', [], [:content_id])
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

      expect(page.current_path).to eq("/manuals")
      expect(page).to have_content("You aren't permitted to access AAIB Reports")
    end

    scenario "visiting a format which doesn't exist" do
      visit "/a-format-which-doesnt-exist"

      expect(page.current_path).to eq("/manuals")
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

      expect(page.current_path).to eq("/manuals")
      expect(page).to have_content("You aren't permitted to access CMA Cases")
    end
  end
end
