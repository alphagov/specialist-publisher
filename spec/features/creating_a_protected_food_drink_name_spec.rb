require "spec_helper"

RSpec.feature "Creating a Protected Food Drink Name", type: :feature do
  let(:fields)            { %i[base_path content_id public_updated_at title publication_state] }
  let(:protected_food_drink_name) { FactoryBot.create(:protected_food_drink_name) }
  let(:content_id)        { protected_food_drink_name["content_id"] }
  let(:public_updated_at) { protected_food_drink_name["public_updated_at"] }

  before do
    log_in_as_editor(:protected_food_drink_name_editor)

    Timecop.freeze(Time.zone.parse(public_updated_at))
    allow(SecureRandom).to receive(:uuid).and_return(content_id)

    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links

    stub_publishing_api_has_item(protected_food_drink_name)
  end

  scenario "with valid data" do
    visit "/protected-food-drink-names/new"

    expect(page.status_code).to eq(200)
    expect(page).to have_css("div.govspeak-help")
    expect(page).to have_content("To add an attachment, please save the draft first.")
    title = "Example Protected Food Drink Name"
    summary = "This is the summary of an example protected food name"
    fill_in "Title", with: title
    fill_in "Registered name", with: title
    fill_in "Summary", with: summary
    fill_in "Body", with: "## Header#{"\n\nThis is the long body of an example protected food name" * 10}"
    select "Foods: designated origin and geographical indication", from: "Register"
    select "Registered", from: "Status"
    select "1.1 Fresh meat (and offal)", from: "Class category"
    select "Protected Geographical Indication (PGI)", from: "Protection type"
    select "United Kingdom", from: "Country"
    select "Wine", from: "Traditional term grapevine product category"
    fill_in "[protected_food_drink_name]date_registration(1i)", with: "2014"
    fill_in "[protected_food_drink_name]date_registration(2i)", with: "01"
    fill_in "[protected_food_drink_name]date_registration(3i)", with: "01"

    click_button "Save as draft"
    assert_publishing_api_put_content(content_id)

    expect(page.status_code).to eq(200)
    expect(page).to have_content("Created Example Protected Food Drink Name")
  end

  scenario "with no data" do
    visit "/protected-food-drink-names/new"

    expect(page.status_code).to eq(200)
    click_button "Save as draft"

    expect(page.status_code).to eq(422)

    expect(page).to have_content("Title can't be blank")
    expect(page).to have_content("Body can't be blank")
    expect(page).to have_content("Register can't be blank")
    expect(page).to have_content("Status can't be blank")
    expect(page).to have_content("Class category can't be blank")
    expect(page).to have_content("Protection type can't be blank")
    expect(page).to have_content("Country of origin can't be blank")
  end

  scenario "with invalid data" do
    visit "/protected-food-drink-names/new"

    expect(page.status_code).to eq(200)

    title = "Example Protected Food Drink Name"
    summary = "This is the summary of an example protected food name"
    fill_in "Title", with: title
    fill_in "Summary", with: summary
    fill_in "Body", with: "<script>alert('hello')</script>"

    click_button "Save as draft"

    expect(page.status_code).to eq(422)

    expect(page).to have_content("Body cannot include invalid Govspeak")
  end
end
