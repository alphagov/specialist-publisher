RSpec.feature "Creating a Statutory Instrument", type: :feature do
  def statutory_instrument_content_item_links
    {
      "content_id" => "4a656f42-35ad-4034-8c7a-08870db7fffe",
      "links" => {
        "organisations" => ["957eb4ec-089b-4f71-ba2a-dc69ac8919ea"]
      }
    }
  end

  let(:statutory_instrument) { FactoryBot.create(:statutory_instrument) }
  let(:organisations) {
    [
      { "content_id" => "12345", "title" => "Org 1" },
      { "content_id" => "67890", "title" => "Org 2" }
    ]
  }
  let(:content_id) { statutory_instrument['content_id'] }
  let(:save_button_disable_with_message) { page.find_button('Save as draft')["data-disable-with"] }

  before do
    log_in_as_editor(:gds_editor)

    allow(SecureRandom).to receive(:uuid).and_return(content_id)
    Timecop.freeze(Time.parse("2015-12-03 16:59:13 UTC"))

    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links

    publishing_api_has_content([statutory_instrument], hash_including(document_type: StatutoryInstrument.document_type))
    publishing_api_has_item(statutory_instrument)
    publishing_api_has_content(organisations, hash_including(document_type: Organisation.document_type))
  end

  scenario "getting to the new document page" do
    visit "/statutory-instruments"

    click_link "Add another Statutory instrument"

    expect(page.status_code).to eq(200)
    expect(page.current_path).to eq("/statutory-instruments/new")
  end

  scenario "saving valid form values" do
    visit "/statutory-instruments/new"

    fill_in "Title", with: "Statutory instrument"
    fill_in "Summary", with: "This is a statutory instrument"
    fill_in "Body", with: "## What is a statutory instrument?"

    fill_in "statutory_instrument_sift_end_date_year", with: "2017"
    fill_in "statutory_instrument_sift_end_date_month", with: "02"
    fill_in "statutory_instrument_sift_end_date_day", with: "01"

    fill_in "statutory_instrument_laid_date_year", with: "2017"
    fill_in "statutory_instrument_laid_date_month", with: "02"
    fill_in "statutory_instrument_laid_date_day", with: "01"

    select "Oil and gas", from: "Subject"
    select "Org 1", from: "Publishing organisation"
    select "Org 2", from: "Other associated organisations"

    click_on "Save"

    expect(page.body).to have_content("Created Statutory instrument")
  end
end
