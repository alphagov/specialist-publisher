require "spec_helper"

RSpec.feature "Creating a residential property tribunal decision", type: :feature do
  let(:tribunal_decision) { FactoryBot.create(:residential_property_tribunal_decision) }
  let(:content_id)        { tribunal_decision["content_id"] }
  let(:public_updated_at) { tribunal_decision["public_updated_at"] }

  before do
    log_in_as_editor(:moj_editor)

    Timecop.freeze(Time.zone.parse(public_updated_at))
    allow(SecureRandom).to receive(:uuid).and_return(content_id)

    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links

    stub_publishing_api_has_item(tribunal_decision)
  end

  scenario "with valid data" do
    visit "/residential-property-tribunal-decisions/new"
    title = "Example Residential property tribunal decision"
    summary = "This is the summary of an example Residential property tribunal decision"

    expect(page.status_code).to eq(200)

    fill_in "Title", with: title
    fill_in "Summary", with: summary
    fill_in "Body", with: "## Header#{"\n\nThis is the long body of an example Residential property tribunal decision" * 10}"
    select "Park homes", from: "Category"
    select "Park homes - Site licence - payment of annual fee", from: "Sub-category"
    fill_in "residential_property_tribunal_decision[tribunal_decision_decision_date(1i)]", with: "2018"
    fill_in "residential_property_tribunal_decision[tribunal_decision_decision_date(2i)]", with: "01"
    fill_in "residential_property_tribunal_decision[tribunal_decision_decision_date(3i)]", with: "01"
    fill_in "Hidden indexable content", with: "hidden text goes here"

    expect(page).to have_css("div.govspeak-help")
    expect(page).to have_content("To add an attachment, please save the draft first.")

    click_button "Save as draft"

    expect(page.status_code).to eq(200)
    assert_publishing_api_put_content(content_id)

    expect(page.status_code).to eq(200)
    expect(page).to have_content("Created Example Residential property tribunal decision")
  end

  scenario "with no data" do
    visit "/residential-property-tribunal-decisions/new"

    expect(page.status_code).to eq(200), page.html

    click_button "Save as draft"

    expect(page.status_code).to eq(422)

    expect(page).to have_content("Title can't be blank")
    expect(page).to have_content("Summary can't be blank")
    expect(page).to have_content("Body can't be blank")
    expect(page).to have_content("Tribunal decision category can't be blank")
    expect(page).to have_content("Tribunal decision sub category can't be blank")
    expect(page).to have_content("Tribunal decision decision date can't be blank")

    expect(page).to_not have_content("Hidden indexable content can't be blank")
  end

  scenario "with invalid data" do
    visit "/residential-property-tribunal-decisions/new"

    expect(page.status_code).to eq(200)

    fill_in "Title", with: "Example Residential property tribunal decision"
    fill_in "Summary", with: "This is the summary of an example Residential property tribunal decision"
    fill_in "Body", with: "<script>alert('hello')</script>"
    select "Rents", from: "Category"
    select "Park homes - Site licence - payment of annual fee", from: "Sub-category"

    click_button "Save as draft"

    expect(page.status_code).to eq(422)

    expect(page).to have_content("Body cannot include invalid Govspeak")
    expect(page).to have_content("Tribunal decision sub category must belong to the selected tribunal decision category")
  end
end
