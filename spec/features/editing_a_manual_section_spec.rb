require 'spec_helper'

RSpec.feature "editing a manual section" do
  context 'as a GDS editor' do
    let(:manual) { Payloads.manual_content_item }
    let(:manual_links) { Payloads.manual_links }
    let(:sections) { Payloads.section_content_items }
    let(:sections_links) { Payloads.section_links }

    let(:manual_content_id) { manual['content_id'] }

    let(:section_content_ids) { sections.map { |section| section['content_id'] } }

    before do
      log_in_as_editor(:gds_editor)

      publishing_api_has_item(manual)
      publishing_api_has_links(manual_links)

      sections.each { |section| publishing_api_has_item(section) }
      sections_links.each { |section_links| publishing_api_has_links(section_links) }

      section_content_ids.each do |section_content_id|
        stub_publishing_api_put_content(section_content_id, {})
        stub_publishing_api_patch_links(section_content_id, {})
      end
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
          }
        }
      )
      assert_publishing_api_put_content(section_content_ids[0], expected_json)
    end

    let(:file_name) { "section_image.jpg" }
    let(:asset_url) { "http://assets-origin.dev.gov.uk/media/56c45553759b740609000000/#{file_name}" }
    let(:asset_manager_response) {
      {
        id: 'http://asset-manager.dev.gov.uk/assets/another_image_id',
        file_url: asset_url
      }
    }
    before do
      stub_request(:post, "#{Plek.find('asset-manager')}/assets")
        .with(body: %r{.*})
        .to_return(body: JSON.dump(asset_manager_response), status: 201)
    end

    scenario "adding an attachment" do
      visit manual_path(manual_content_id)
      click_link 'First section'
      click_link 'Edit section'

      click_link "Add attachment"
      expect(page.status_code).to eq(200)

      fill_in "Title", with: "New section image"
      page.attach_file('attachment_file', "spec/support/images/section_image.jpg")

      click_button "Save attachment"
      expect(page.status_code).to eq(200)

      expect(page).to have_content('Attached New section image')
      expect(page).to have_content("Edit section")
    end

    scenario "editing an attachment" do
      visit manual_path(manual_content_id)
      click_link 'Second section'
      click_link 'Edit section'
      find('.attachments').first(:link, "edit").click

      expect(page.status_code).to eq(200)

      fill_in "Title", with: "Updated section image"
      page.attach_file('attachment_file', "spec/support/images/updated_section_image.jpg")

      click_button("Save attachment")
      expect(page.status_code).to eq(200)
      expect(page).to have_content("Attachment succesfully updated")
    end
  end
end
