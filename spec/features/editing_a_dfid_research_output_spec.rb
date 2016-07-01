require 'spec_helper'

RSpec.feature "Editing a DFID Research Output", type: :feature do
  let(:research_output)   { FactoryGirl.create(:dfid_research_output) }
  let(:content_id)        { research_output['content_id'] }
  let(:public_updated_at) { research_output['public_updated_at'] }

  before do
    allow_any_instance_of(DocumentPolicy).to receive(:departmental_editor).and_return(true)

    log_in_as_editor(:dfid_editor)

    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links

    publishing_api_has_item(research_output)
  end

  scenario "with valid data" do
    visit  "/dfid-research-outputs/#{content_id}/edit"
    expect(page).to have_css('div.govspeak-help')

    title = "Example DFID Research output"
    summary = "This is the summary of an example DFID research output"

    fill_in "Title", with: title
    fill_in "Summary", with: summary
    fill_in "Body", with: ("## Header" + ("\n\nThis is the long body of an example DFID research output" * 10))
    fill_in "First published at", with: "2013-01-01"
    select "United Kingdom", from: "Countries"

    click_button "Save as draft"
    assert_publishing_api_put_content(content_id)

    expect(page.status_code).to eq(200)
    expect(page).to have_content("Updated Example DFID Research output")
  end
end
