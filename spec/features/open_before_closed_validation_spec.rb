require "spec_helper"

RSpec.feature "Testing the open before closed date validation", type: :feature do
  let(:cma_case) { FactoryBot.create(:cma_case) }
  let(:content_id) { cma_case["content_id"] }

  before do
    log_in_as_editor(:cma_editor)

    allow(SecureRandom).to receive(:uuid).and_return(content_id)
    Timecop.freeze(Time.zone.parse("2015-12-03 16:59:13 UTC"))

    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links

    stub_publishing_api_has_content([cma_case], hash_including(document_type: CmaCase.document_type))
    stub_publishing_api_has_item(cma_case)
  end

  def fill_in_cma_case_form(opened_date:, closed_date:)
    visit "/cma-cases/new"

    fill_in "Title", with: "Example CMA Case"
    fill_in "Summary", with: "This is the summary of an example CMA case"
    fill_in "Body", with: "Body of text"
    fill_in "cma_case[opened_date(1i)]", with: opened_date[:year]
    fill_in "cma_case[opened_date(2i)]", with: opened_date[:month]
    fill_in "cma_case[opened_date(3i)]", with: opened_date[:day]
    fill_in "cma_case[closed_date(1i)]", with: closed_date[:year]
    fill_in "cma_case[closed_date(2i)]", with: closed_date[:month]
    fill_in "cma_case[closed_date(3i)]", with: closed_date[:day]
    select "CA98 and civil cartels", from: "Case type"
    select "Open", from: "Case state"
    select "Energy", from: "Market sector"
  end

  scenario "with closed date before opened date" do
    fill_in_cma_case_form(
      opened_date: { year: "2016", month: "02", day: "14" },
      closed_date: { year: "2015", month: "02", day: "14" },
    )

    click_button "Save as draft"

    expect(page.status_code).to eq(422)
    expect(page).to have_css(".elements-error-summary")
    expect(page).to have_css(".elements-error-message")
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Opened date must be before closed date")
  end

  scenario "with blank opened date and filled out closed date" do
    fill_in_cma_case_form(
      opened_date: { year: "", month: "", day: "" },
      closed_date: { year: "2015", month: "02", day: "14" },
    )

    click_button "Save as draft"

    expect(page.status_code).to eq(200)
    expect(page).to have_content("Created Example CMA Case")
  end

  scenario "with blank closed date and filled out opened date" do
    fill_in_cma_case_form(
      opened_date: { year: "2015", month: "02", day: "14" },
      closed_date: { year: "", month: "", day: "" },
    )

    click_button "Save as draft"

    expect(page.status_code).to eq(200)
    expect(page).to have_content("Created Example CMA Case")
  end

  scenario "with blank closed date and opened date" do
    fill_in_cma_case_form(
      opened_date: { year: "", month: "", day: "" },
      closed_date: { year: "", month: "", day: "" },
    )

    click_button "Save as draft"

    expect(page.status_code).to eq(200)
    expect(page).to have_content("Created Example CMA Case")
  end
end
