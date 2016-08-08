require 'spec_helper'

RSpec.feature "Unpublishing a CMA Case", type: :feature do
  let(:content_id) { item['content_id'] }

  before do
    log_in_as_editor(:cma_editor)
    publishing_api_has_item(item)
    stub_publishing_api_unpublish(content_id, body: { type: 'gone' })
    stub_any_rummager_delete_content
  end

  context "a published document" do
    let(:item) {
      FactoryGirl.create(:cma_case,
        title: "Example CMA Case",
        publication_state: "published")
    }

    scenario "clicking the unpublish button redirects back to the show page" do
      visit document_path(content_id: content_id, document_type_slug: "cma-cases")
      expect(page).to have_content("Example CMA Case")
      click_button "Unpublish document"
      expect(page.status_code).to eq(200)
      expect(page).to have_content("Unpublished Example CMA Case")

      assert_publishing_api_unpublish(content_id)
    end

    scenario "writers don't see a unpublish document button" do
      log_in_as_editor(:cma_writer)

      visit document_path(content_id: content_id, document_type_slug: "cma-cases")

      expect(page).to have_no_selector(:button, 'Unpublish document')
    end
  end

  context "publishing-api returns error" do
    let(:item) {
      FactoryGirl.create(:cma_case,
        title: "Example CMA Case",
        publication_state: "published")
    }

    scenario "clicking the unpublish button shows an error message" do
      stub_publishing_api_unpublish(content_id, { body: { type: 'gone' } }, status: 409)

      visit document_path(content_id: content_id, document_type_slug: "cma-cases")
      expect(page).to have_content("Example CMA Case")
      click_button "Unpublish document"
      expect(page.status_code).to eq(200)
      expect(page).to have_content("There was an error unpublishing Example CMA Case. Please try again later.")
    end
  end
end
