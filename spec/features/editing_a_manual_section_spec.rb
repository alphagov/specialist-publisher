require 'spec_helper'

RSpec.feature "editing a manual section" do
  context 'as a GDS editor' do
    let(:manual) { Payloads.manual_content_item }
    let(:manual_links) { Payloads.manual_links }
    let(:sections) { Payloads.section_content_items }
    let(:sections_links) { Payloads.section_links }

    let(:manual_content_id) { manual['content_id'] }

    let(:section_content_id) { sections.first['content_id'] }

    before do
      log_in_as_editor(:gds_editor)

      publishing_api_has_item(manual)
      publishing_api_has_links(manual_links)

      sections.each { |section| publishing_api_has_item(section) }
      sections_links.each { |section_links| publishing_api_has_links(section_links) }

      stub_publishing_api_put_content(section_content_id, {})
      stub_publishing_api_patch_links(section_content_id, {})
    end

    scenario 'editing a section of a manual' do
      visit manual_path(manual_content_id)
      click_link 'First section'
      click_link 'Edit section'

      expect(page.status_code).to eq(200)
      
      fill_in "Title", with: "My updated first section"

      fill_in "Summary", with: "Updated summary of first section"

      fill_in "Body", with: "The updated body of my first section."

      click_button "Save as draft"

      expect(page.status_code).to eq(200)
      expect(page).to have_content("My updated first section has been updated")

      expected_json = request_json_includes(
        'title' => 'My updated first section',
        'description' => 'Updated summary of first section',
        'details' => {
          'body' => 'The updated body of my first section.',
          'manual' => {
            'base_path' => '/guidance/a-manual'
          },
          'organisations' => []
        }
      )
      assert_publishing_api_put_content(section_content_id, expected_json)
    end
  end
end
