require 'spec_helper'

RSpec.feature "Access control", type: :feature do
  def log_in_as_editor(editor)
    user = FactoryGirl.create(editor)
    GDS::SSO.test_user = user
  end

  before do
    fields = [
      :base_path,
      :content_id,
    ]

    publishing_api_has_fields_for_format('specialist_document', [], fields)
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
end
