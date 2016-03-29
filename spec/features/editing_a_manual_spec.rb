require 'spec_helper'

RSpec.feature 'editing a manual' do

  let(:manual_content_item) { Payloads.manual_content_item({"title" => "Example manual"}) }
  let(:manual_links) { Payloads.manual_links }
  let(:section_content_items) { Payloads.section_content_items }
  let(:section_links) { Payloads.section_links }

  before do
    log_in_as_editor(:gds_editor)
    publishing_api_has_fields_for_document("manual", [manual_content_item], [:content_id])
    publishing_api_has_fields_for_document("manual_section", section_content_items.map { |section| { content_id: section["content_id"] } }, [:content_id])
    stub_publishing_api_put_content(manual_content_item["content_id"], {})

    content_items = [manual_content_item] + section_content_items

    content_items.each do |payload|
      publishing_api_has_item(payload)
    end

    links = [manual_links] + section_links

    links.each do |link_set|
      publishing_api_has_links(link_set)
    end
  end

  scenario 'from the index page' do
    visit "/manuals"
    click_link 'Example manual'
    click_link 'Edit manual'

    expect(page.status_code).to eq(200)

    fill_in('Title', :with => 'Edited title')
    fill_in('Summary', :with => 'Edited summary')
    fill_in('Body', :with => 'Edited body')

    click_button 'Save as draft'

    expect(page.current_path).to eq(manual_path(manual_content_item['content_id']))
    expect(page.status_code).to eq(200)
    expect(page).to have_content('Edited title')
  end
end

