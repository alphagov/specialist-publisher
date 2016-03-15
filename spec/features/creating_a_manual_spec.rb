require 'spec_helper'

RSpec.feature "Creating a Manual", type: :feature do
  context 'as a GDS editor' do
    before do
      log_in_as_editor(:gds_editor)

      publishing_api_has_fields_for_format("manual", [], [:content_id])
    end

    scenario 'from the index page to /manuals/new' do
      visit '/manuals'

      expect(page).to have_content("New manual")

      click_link "New manual"

      expect(page.status_code).to eq(200)
      expect(page.current_path).to eq("/manuals/new")
    end

    scenario 'creating a new valid manual' do
      visit '/manuals/new'

      expect(page).to have_field('Title')
      fill_in "Title", with: "My New Manual"

      expect(page).to have_field('Summary')
      fill_in "Summary", with: "Summary of new manual"

      expect(page).to have_field('Body')
      fill_in "Body", with: "The body of my new manual. The body of my new manual. The body of my new manual."

      click_button "Save as draft"
    end
  end
end