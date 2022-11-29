require "spec_helper"

RSpec.feature "The root specialist-publisher page", type: :feature do
  context "when logged in as a GDS editor" do
    before do
      stub_publishing_api_has_content([], hash_including(document_type: CmaCase.document_type))
      stub_publishing_api_has_content([], hash_including(document_type: AaibReport.document_type))
      log_in_as_editor(:gds_editor)
    end

    it "grants access to view all finders including pre-production" do
      visit "/"

      click_link("AAIB Reports", match: :first)

      count = Dir["lib/documents/schemas/*.json"].length
      expect(page).to have_css(".dropdown-menu:nth-of-type(1) li", count:)
    end

    it "selects and navigates to cma case finder" do
      visit "/"

      expect(page).to have_selector("h1", text: "AAIB Reports")

      click_link("AAIB Reports", match: :first)

      expect(page).to have_text("CMA Cases")

      click_link("CMA Cases")

      expect(page).to have_text("Add another CMA Case")
    end

    it "has expected finders" do
      visit "/"

      click_link("AAIB Reports", match: :first)

      expect(page).to have_text("AAIB Reports")
      expect(page).to have_text("Asylum Support Decisions")
      expect(page).to have_text("Business Finance Support Schemes")
      expect(page).to have_text("CMA Cases")
      expect(page).to have_text("Countryside Stewardship Grants")
      expect(page).to have_text("Drug Safety Updates")
      expect(page).to have_text("EAT Decisions")
      expect(page).to have_text("ESI Funds")
      expect(page).to have_text("ET Decisions")
      expect(page).to have_text("EU Withdrawal Act 2018 statutory instruments")
      expect(page).to have_text("Export health certificates")
      expect(page).to have_text("International Development Funds")
      expect(page).to have_text("Licences")
      expect(page).to have_text("MAIB Reports")
      expect(page).to have_text("Medical Safety Alerts")
      expect(page).to have_text("Protected Geographical Food and Drink Name")
      expect(page).to have_text("RAIB Reports")
      expect(page).to have_text("Research for Development Outputs")
      expect(page).to have_text("Residential Property Tribunal Decisions")
      expect(page).to have_text("Service Standard Reports")
      expect(page).to have_text("Tax Tribunal Decisions")
      expect(page).to have_text("UK Market Conformity Assessment Bodies")
      expect(page).to have_text("UTAAC Decisions")
    end
  end

  context "when logged in as a CMA editor" do
    before do
      stub_publishing_api_has_content([], hash_including(document_type: CmaCase.document_type))
      log_in_as_editor(:cma_editor)
    end

    it "displays only the CMA Cases finder" do
      visit "/"

      expect(page).to have_selector("h1", text: "CMA Cases")

      expect(page).to have_text("CMA Cases")

      expect(page).to have_css(".navbar-nav li a", count: 2)

      click_link("CMA Cases")

      expect(page).to have_content("Add another CMA Case")
    end
  end
end
