require "spec_helper"

RSpec.feature "Viewing the finders index page", type: :feature do
  context "when logged in as a GDS editor" do
    before do
      log_in_as_editor(:gds_editor)
    end

    it "root redirects to /finders" do
      visit "/"

      expect(page.current_path).to eq("/finders")
      expect(page).to have_content("All finders")
    end

    it "grants access to view all finders" do
      visit "/"

      count = Dir["lib/documents/schemas/*.json"].length
      expect(page).to have_css(".gem-c-document-list li", count:)
    end

    it "selects and navigates to CMA cases finder" do
      stub_publishing_api_has_content([], hash_including(document_type: CmaCase.document_type))

      visit "/"
      click_link("CMA Cases")

      expect(page).to have_text("Add another CMA Case")
    end

    it "has expected finders" do
      visit "/"

      FinderSchema.document_models.each do |document_model|
        expect(page).to have_link(document_model.title.pluralize, href: documents_path(document_model.admin_slug))
      end
    end
  end

  context "when logged in as CMA editor" do
    it "displays all finders under the CMA organisation" do
      log_in_as_editor(:cma_editor)

      visit "/"

      expect(page).to have_text("CMA Cases")
      expect(page).to have_text("DRCF digital markets research")

      expect(page).to have_css(".gem-c-document-list li", count: 2)
    end
  end
end
