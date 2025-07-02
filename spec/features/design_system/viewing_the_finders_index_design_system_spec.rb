require "spec_helper"

RSpec.feature "Viewing the finders index page", type: :feature do
  context "when logged in as a GDS editor" do
    before do
      log_in_as_design_system_editor(:gds_editor)
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

  context "when logged in as Licence Transaction editor" do
    it "displays only the Licences finder" do
      log_in_as_design_system_editor(:licence_transaction_editor)

      visit "/"

      expect(page).to have_text("Licences")

      expect(page).to have_css(".gem-c-document-list li", count: 1)
    end
  end
end
