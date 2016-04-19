require 'spec_helper'

RSpec.feature "Viewing a Manual", type: :feature do
  let(:manual_content_item) { Payloads.manual_content_item }
  let(:manual_links) { Payloads.manual_links }
  let(:section_content_items) { Payloads.section_content_items }
  let(:section_links) { Payloads.section_links }
  let(:fields) { %i[content_id description title details public_updated_at publication_state base_path update_type] }

  before do
    publishing_api_has_content([manual_content_item], document_type: "manual", fields: fields, per_page: 10000)
    publishing_api_has_content(
      section_content_items.map do |section|
        {
          content_id: section["content_id"]
        }
      end,
      document_type: "manual_section",
      fields: [:content_id]
    )

    content_items = [manual_content_item] + section_content_items

    content_items.each do |payload|
      publishing_api_has_item(payload)
    end
  end

  context 'as a GDS editor' do
    before do
      log_in_as_editor(:gds_editor)

      links = [manual_links] + section_links

      links.each do |link_set|
        publishing_api_has_links(link_set)
        link_set['links']['organisations'].each do |organisation|
          organisation = {
            content_id: organisation,
            base_path: "/government/organisations/#{organisation}",
            title: 'Government Digital Service'
          }
          publishing_api_has_item(organisation)
        end
      end
    end

    scenario "from the index" do
      visit "/manuals"

      expect(page.status_code).to eq(200)
      expect(page).to have_content("A Manual")
      expect(page).to have_content("Government Digital Service")

      click_link "A Manual"

      expect(page.status_code).to eq(200)
      expect(page).to have_content("First section")
      expect(page).to have_content("Second section")
    end
  end

  context 'as a CMA editor' do
    let(:manual_content_item) { Payloads.manual_content_item(title: "A CMA Manual") }
    let(:manual_links) {
      Payloads.manual_links(
        "links" => {
          "organisations" => ["957eb4ec-089b-4f71-ba2a-dc69ac8919ea"]
        }
      )
    }

    before do
      log_in_as_editor(:cma_editor)

      links = [manual_links] + section_links

      links.each do |link_set|
        publishing_api_has_links(link_set)
        link_set['links']['organisations'].each do |organisation|
          organisation = {
            content_id: organisation,
            base_path: "/government/organisations/#{organisation}",
            title: 'Competition And Markets Authority'
          }
          publishing_api_has_item(organisation)
        end
      end
    end

    scenario "from the index" do
      visit "/manuals"

      expect(page.status_code).to eq(200)
      expect(page).to have_content("A CMA Manual")
      expect(page).to_not have_content("Competition And Markets Authority")

      click_link "A CMA Manual"

      expect(page.status_code).to eq(200)
      expect(page).to have_content("First section")
      expect(page).to have_content("Second section")
    end

    scenario "which doesnt exist" do
      content_id = "a-case-that-doesnt-exist"
      publishing_api_does_not_have_item(content_id)
      publishing_api_does_not_have_links(content_id)

      visit "/manuals/#{content_id}"

      expect(page.current_path).to eq("/manuals")
      expect(page).to have_content("Manual not found")
    end
  end
end
