require 'spec_helper'

RSpec.feature "Creating a DFID Research Output", type: :feature do
  let(:fields)            { [:base_path, :content_id, :public_updated_at, :title, :publication_state] }
  let(:research_output)   { FactoryGirl.create(:dfid_research_output) }
  let(:content_id)        { research_output['content_id'] }
  let(:public_updated_at) { research_output['public_updated_at'] }

  before do
    allow_any_instance_of(DocumentPolicy).to receive(:departmental_editor).and_return(true)
    log_in_as_editor(:dfid_editor)

    Timecop.freeze(Time.parse(public_updated_at))
    allow(SecureRandom).to receive(:uuid).and_return(content_id)

    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links

    publishing_api_has_item(research_output)
  end

  scenario "with valid data" do
    visit "/dfid-research-outputs/new"

    title = "Example DFID Research output"
    summary = "This is the summary of an example DFID research output"

    fill_in "Title", with: title
    fill_in "Summary", with: summary
    fill_in "Body", with: ("## Header" + ("\n\nThis is the long body of an example DFID research output" * 10))
    fill_in "First published at", with: "2013-01-01"
    select "Infrastructure", from: "Themes"

    expect(page).to have_css('div.govspeak-help')
    expect(page).to have_content('To add an attachment, please save the draft first.')

    click_button "Save as draft"
    assert_publishing_api_put_content(content_id)

    expect(page.status_code).to eq(200)
    expect(page).to have_content("Created Example DFID Research output")
  end

  scenario "with no data" do
    visit "/dfid-research-outputs/new"

    click_button "Save as draft"

    expect(page.status_code).to eq(422)

    expect(page).to have_content("Title can't be blank")
    expect(page).to have_content("Summary can't be blank")
    expect(page).to have_content("Body can't be blank")
    expect(page).not_to have_content("Country can't be blank")
  end

  scenario "with invalid data" do
    visit "/dfid-research-outputs/new"

    fill_in "Title", with: "Example DFID Research output"
    fill_in "Summary", with: "This is the summary of an example DFID Research output"
    fill_in "Body", with: "<script>alert('hello')</script>"

    click_button "Save as draft"

    expect(page.status_code).to eq(422)

    expect(page).to have_content("Body cannot include invalid Govspeak")
  end
end
