require 'spec_helper'

RSpec.feature "Withdrawing a CMA Case", type: :feature do
  let(:content_id) { item['content_id'] }

  before do
    log_in_as_editor(:cma_editor)
    publishing_api_has_item(item)
    stub_publishing_api_unpublish(content_id, body: { type: 'gone' })
  end

  context "a published document" do
    let(:item) {
      FactoryGirl.create(:cma_case,
        title: "Example CMA Case",
        publication_state: "live")
    }

    scenario "clicking the withdraw button redirects back to the show page" do
      visit document_path(content_id: content_id, document_type_slug: "cma-cases")
      expect(page).to have_content("Example CMA Case")
      click_button "Withdraw document"
      expect(page.status_code).to eq(200)
      expect(page).to have_content("Withdrawn Example CMA Case")

      assert_publishing_api_unpublish(content_id)
    end
  end

  context "publishing-api returns error" do
    let(:item) {
      FactoryGirl.create(:cma_case,
        title: "Example CMA Case",
        publication_state: "live")
    }

    scenario "clicking the withdraw button shows an error message" do
      stub_publishing_api_unpublish(content_id, { body: { type: 'gone' } }, status: 409)

      visit document_path(content_id: content_id, document_type_slug: "cma-cases")
      expect(page).to have_content("Example CMA Case")
      click_button "Withdraw document"
      expect(page.status_code).to eq(200)
      expect(page).to have_content("There was an error withdrawing Example CMA Case. Please try again later.")
    end
  end
end
