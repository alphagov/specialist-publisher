require 'spec_helper'

RSpec.feature "Viewing a Manual and its Sections", type: :feature do
  context 'as a GDS editor' do
    let(:manual_content_item) { Payloads.manual_content_item }
    let(:manual_links) { Payloads.manual_links }
    let(:section_content_items) { Payloads.section_content_items }
    let(:section_links) { Payloads.section_links }
    
    before do
      log_in_as_editor(:gds_editor)

      publishing_api_has_fields_for_document("manual", [manual_content_item], [:content_id])
      publishing_api_has_fields_for_document("manual_section", section_content_items.map { |section| { content_id: section["content_id"] } }, [:content_id])

      content_items = [manual_content_item] + section_content_items

      content_items.each do |payload|
        publishing_api_has_item(payload)
      end

      links = [manual_links] + section_links

      links.each do |link_set|
        publishing_api_has_links(link_set)
      end
    end

    scenario "from the index" do
      visit "/manuals"

      expect(page.status_code).to eq(200)
      expect(page).to have_content("A Manual")

      click_link "A Manual"

      expect(page.status_code).to eq(200)
      expect(page).to have_content("First section")
      expect(page).to have_content("Second section")
    end

    scenario "viewing a Section" do
      visit "/manuals/#{manual_content_item['content_id']}"

      expect(page.status_code).to eq(200)
      expect(page).to have_content("First section")

      click_link "First section"

      expect(page.status_code).to eq(200)
      expect(page).to have_content("This is a manual's first section")
    end

    scenario "requesting a Section with the wrong content id" do
      invalid_content_id = SecureRandom.uuid
      publishing_api_does_not_have_item(invalid_content_id)

      visit "/manuals/#{manual_content_item['content_id']}/sections/#{invalid_content_id}"

      expect(current_path).to eq(manuals_path)
      expect(page).to have_content "Section not found"
    end

    scenario "requesting a Section with the wrong manual content id" do
      visit "/manuals/#{SecureRandom.uuid}/sections/#{section_content_items.first['content_id']}"

      expect(page.current_path).to eq(manuals_path)
      expect(page).to have_content "Section does exist, but not within the supplied manual"
    end
  end
end
