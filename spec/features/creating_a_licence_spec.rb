require "spec_helper"

RSpec.feature "Creating a Licence", type: :feature do
  let(:fields)              { %i[base_path content_id public_updated_at title publication_state] }
  let(:licence_transaction) { FactoryBot.create(:licence_transaction) }
  let(:content_id)          { licence_transaction["content_id"] }
  let(:public_updated_at)   { licence_transaction["public_updated_at"] }
  let(:organisations) do
    [
      { "content_id" => "12345", "title" => "Org 1" },
      { "content_id" => "67890", "title" => "Org 2" },
    ]
  end

  before do
    log_in_as_editor(:licence_transaction_editor)
    allow(SecureRandom).to receive(:uuid).and_return(content_id)

    stub_publishing_api_has_content([licence_transaction], hash_including(document_type: LicenceTransaction.document_type))
    stub_publishing_api_has_item(licence_transaction)
    stub_publishing_api_has_content(organisations, hash_including(document_type: Organisation.document_type))

    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links
  end

  scenario "creating a new licence" do
    visit "/licences"
    click_link "Add another Licence"
    expect(page.status_code).to eq(200)
    expect(page.current_path).to eq("/licences/new")
  end

  scenario "saving a new licence case with no data" do
    visit "/licences/new"

    click_button "Save as draft"

    expect(page.status_code).to eq(422)

    expect(page).to have_content("Please fix the following errors")
    expect(page).to have_content("Title can't be blank")
    expect(page).to have_content("Summary can't be blank")
    expect(page).to have_content("Body can't be blank")
  end

  scenario "saving a new licence with valid data" do
    visit "/licences/new"

    fill_in "Title", with: "Example licence"
    fill_in "Summary", with: "This is the summary of a licence"
    fill_in "Body", with: "## Header#{"\n\nThis is the long body of a licence" * 2}"
    select "England", from: "Location"
    select "Advertising and marketing", from: "Industry"
    fill_in "URL for \"Start Now\" button", with: "https://www.gov.uk"
    fill_in "Name of website where you apply", with: "on GOV.UK"

    click_button "Save as draft"
    assert_publishing_api_put_content(content_id)

    expect(page.status_code).to eq(200)
    expect(page).to have_content("Created Example licence")
  end
end
