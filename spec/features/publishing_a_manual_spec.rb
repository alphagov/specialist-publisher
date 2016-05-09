require 'spec_helper'

RSpec.feature "Publishing a Manual", type: :feature do
  let(:manual_content_item) { Payloads.manual_content_item }
  let(:manual_links) { Payloads.manual_links }
  let(:manual_organisation_content_id) { manual_links["links"]["organisations"].first }
  let(:section_content_items) { Payloads.section_content_items }
  let(:section_links) { Payloads.section_links }
  let(:fields) { %i[content_id description title details public_updated_at publication_state base_path update_type] }
  before do
    publishing_api_has_content([manual_content_item], document_type: "manual", fields: fields, per_page: 10000)
    publishing_api_has_content(section_content_items.map { |section| { content_id: section["content_id"] } }, document_type: "manual_section", fields: fields, per_page: 10000)

    content_items = [manual_content_item] + section_content_items

    content_items.each do |payload|
      publishing_api_has_item(payload)
    end

    links = [manual_links] + section_links

    links.each do |link_set|
      publishing_api_has_links(link_set)
      link_set['links']['organisations'].each do |organisation|
        organisation = { content_id: organisation, base_path: "/government/organisations/#{organisation}" }
        publishing_api_has_item(organisation)
      end
    end
  end

  scenario "GDS editors see a Publish button" do
    log_in_as_editor(:gds_editor)

    visit "/manuals"

    expect(page.status_code).to eq(200)
    expect(page).to have_content("A Manual")

    click_link "A Manual"

    expect(page.status_code).to eq(200)
    expect(page).to have_content("First section")
    expect(page).to have_content("Second section")

    expect(page).to have_selector(:button, 'Publish')

    # the publishing itself hasn't been implemented yet
  end

  scenario "writers don't see a Publish button" do
    log_in_as FactoryGirl.create(:writer, organisation_content_id: manual_organisation_content_id)

    visit "/manuals"

    expect(page.status_code).to eq(200)
    expect(page).to have_content("A Manual")

    click_link "A Manual"

    expect(page).not_to have_selector(:button, 'Publish')
  end
end
