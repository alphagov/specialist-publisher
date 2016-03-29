require 'spec_helper'

RSpec.feature "adding a section to a manual" do
  context 'as a GDS editor' do
    def manual_content_id
      "b1dc075f-d946-4bcb-a5eb-941f8c8188cf"
    end

    def manual_base_path
      "/guidance/my-new-manual"
    end

    def stub_json
      {
        base_path: manual_base_path,
        content_id: manual_content_id,
        title: "My New Manual",
        description: "Summary of new manual",
        details: {
        body: "The body of my new manual. The body of my new manual. The body of my new manual."
      }
      }
    end

    def manual_links
      {
        content_id: manual_content_id,
        links: { }
      }
    end

    before do
      log_in_as_editor(:gds_editor)

      publishing_api_has_fields_for_document("manual", [], [:content_id])

      stub_publishing_api_put_content(manual_content_id, {})
      stub_any_publishing_api_patch_links
      publishing_api_has_item(stub_json)
      publishing_api_has_links(manual_links)
      allow(SecureRandom).to receive(:uuid).and_return(stub_json[:content_id])
    end

    scenario 'adding a valid section to a manual' do
      visit manual_path(manual_content_id)
      click_link 'Add section'

      expect(page.status_code).to eq(200)

      expect(page).to have_field('Title')
      fill_in "Title", with: "My New section"

      expect(page).to have_field('Summary')
      fill_in "Summary", with: "Summary of new section"

      expect(page).to have_field('Body')
      fill_in "Body", with: "The body of my new section. The body of my new section. The body of my new section."

      click_button "Save as draft"

      expect(page.status_code).to eq(200)
      expect(page).to have_content("Summary of new manual")
      expect(page).to have_content("Created My New section")
    end
  end
end

