require "spec_helper"

RSpec.feature "Creating a CMA case", type: :feature do
  def cma_case_content_item_links
    {
      "content_id" => "4a656f42-35ad-4034-8c7a-08870db7fffe",
      "links" => {
        "organisations" => %w[957eb4ec-089b-4f71-ba2a-dc69ac8919ea],
      },
    }
  end

  let(:cma_case) { FactoryBot.create(:cma_case) }
  let(:content_id) { cma_case["content_id"] }
  let(:save_button_disable_with_message) { page.find_button("Save as draft")["data-disable-with"] }

  before do
    log_in_as_editor(:cma_editor)

    allow(SecureRandom).to receive(:uuid).and_return(content_id)
    Timecop.freeze(Time.zone.parse("2015-12-03 16:59:13 UTC"))

    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links

    stub_publishing_api_has_content([cma_case], hash_including(document_type: CmaCase.document_type))
    stub_publishing_api_has_item(cma_case)
  end

  scenario "getting to the new document page" do
    visit "/cma-cases"
    click_link "Add another CMA Case"

    expect(page.status_code).to eq(200)
    expect(page.current_path).to eq("/cma-cases/new")
  end

  scenario "with valid data" do
    visit "/cma-cases/new"

    fill_in "Title", with: "Example CMA Case"
    fill_in "Summary", with: "This is the summary of an example CMA case"
    fill_in "Body", with: "## Header#{"\n\nThis is the long body of an example CMA case" * 2}"
    fill_in "cma_case[opened_date(1i)]", with: "2014"
    fill_in "cma_case[opened_date(2i)]", with: "01"
    fill_in "cma_case[opened_date(3i)]", with: "01"
    select "CA98 and civil cartels", from: "Case type"
    select "Open", from: "Case state"
    select "Energy", from: "Market sector"

    expect(page).to have_css("div.govspeak-help")
    expect(page).to have_content("To add an attachment, please save the draft first.")
    expect(save_button_disable_with_message).to eq("Saving...")

    click_button "Save as draft"

    expected_sent_payload = {
      "base_path" => "/cma-cases/example-cma-case",
      "title" => "Example CMA Case",
      "description" => "This is the summary of an example CMA case",
      "document_type" => "cma_case",
      "schema_name" => "specialist_document",
      "publishing_app" => "specialist-publisher",
      "rendering_app" => "government-frontend",
      "locale" => "en",
      "phase" => "live",
      "details" => {
        "body" => [
          {
            "content_type" => "text/govspeak",
            "content" => "## Header\r\n\r\nThis is the long body of an example CMA case\r\n\r\nThis is the long body of an example CMA case",
          },
        ],
        "metadata" => {
          "opened_date" => "2014-01-01",
          "case_type" => "ca98-and-civil-cartels",
          "case_state" => "open",
          "market_sector" => %w[energy],
        },
        "max_cache_time" => 10,
        "headers" => [
          { "text" => "Header", "level" => 2, "id" => "header" },
        ],
        "temporary_update_type" => false,
      },
      "routes" => [{ "path" => "/cma-cases/example-cma-case", "type" => "exact" }],
      "redirects" => [],
      "update_type" => "major",
      "links" => {
        "finder" => %w[fef4ac7c-024a-4943-9f19-e85a8369a1f3],
      },
    }

    assert_publishing_api_put_content(content_id, expected_sent_payload)

    expect(page.status_code).to eq(200)
    expect(page).to have_content("Created Example CMA Case")
    expect(page).to have_content("Bulk published false")
  end

  scenario "with no data" do
    visit "/cma-cases/new"

    click_button "Save as draft"

    expect(page.status_code).to eq(422)

    expect(page).to have_css(".elements-error-summary")
    expect(page).to have_css(".form-group.elements-error")
    expect(page).to have_css(".elements-error-message")

    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Title can't be blank")
    expect(page).to have_content("Summary can't be blank")
    expect(page).to have_content("Body can't be blank")
    expect(page).to have_content("Market sector can't be blank")
  end

  scenario "with invalid data" do
    visit "/cma-cases/new"

    fill_in "Title", with: "Example CMA Case"
    fill_in "Summary", with: "This is the summary of an example CMA case"
    fill_in "Body", with: "<script>alert('hello')</script>"
    select "CA98 and civil cartels", from: "Case type"
    select "Open", from: "Case state"
    select "Energy", from: "Market sector"

    click_button "Save as draft"

    expect(page.status_code).to eq(422)

    expect(page).to have_css(".elements-error-summary")
    expect(page).to have_css(".elements-error-message")

    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Body cannot include invalid Govspeak")
  end

  scenario "a date with a single digit month and day" do
    visit "/cma-cases/new"

    fill_in "Title", with: "Example CMA Case"
    fill_in "Summary", with: "This is the summary of an example CMA case"
    fill_in "Body", with: "Body of text"
    fill_in "cma_case[opened_date(1i)]", with: "2016"
    fill_in "cma_case[opened_date(2i)]", with: "1"
    fill_in "cma_case[opened_date(3i)]", with: "2"
    select "CA98 and civil cartels", from: "Case type"
    select "Open", from: "Case state"
    select "Energy", from: "Market sector"

    click_button "Save as draft"

    expect(page.status_code).to eq(200)

    expect(page).to have_content("Created Example CMA Case")
  end

  scenario "with an invalid date" do
    visit "/cma-cases/new"

    fill_in "Title", with: "Example CMA Case"
    fill_in "Summary", with: "This is the summary of an example CMA case"
    fill_in "Body", with: "body of text"
    fill_in "cma_case[opened_date(1i)]", with: "2016"
    fill_in "cma_case[opened_date(2i)]", with: "02"
    fill_in "cma_case[opened_date(3i)]", with: "31"
    select "CA98 and civil cartels", from: "Case type"
    select "Open", from: "Case state"
    select "Energy", from: "Market sector"

    click_button "Save as draft"

    expect(page.status_code).to eq(422)

    expect(page).to have_css(".elements-error-summary")
    expect(page).to have_css(".elements-error-message")

    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Opened date is not a valid date")
  end

  scenario "with closed date before opened date" do
    visit "/cma-cases/new"

    fill_in "Title", with: "Example CMA Case"
    fill_in "Summary", with: "This is the summary of an example CMA case"
    fill_in "Body", with: "Body of text"
    fill_in "cma_case[opened_date(1i)]", with: "2016"
    fill_in "cma_case[opened_date(2i)]", with: "02"
    fill_in "cma_case[opened_date(3i)]", with: "14"
    fill_in "cma_case[closed_date(1i)]", with: "2015"
    fill_in "cma_case[closed_date(2i)]", with: "02"
    fill_in "cma_case[closed_date(3i)]", with: "14"
    select "CA98 and civil cartels", from: "Case type"
    select "Open", from: "Case state"
    select "Energy", from: "Market sector"

    click_button "Save as draft"

    expect(page.status_code).to eq(422)

    expect(page).to have_css(".elements-error-summary")
    expect(page).to have_css(".elements-error-message")

    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Opened date must be before closed date")
  end

  scenario "with a blank year but filled out day and month" do
    visit "/cma-cases/new"

    fill_in "Title", with: "Example CMA Case"
    fill_in "Summary", with: "This is the summary of an example CMA case"
    fill_in "Body", with: "Body of text"
    fill_in "cma_case[opened_date(1i)]", with: ""
    fill_in "cma_case[opened_date(2i)]", with: "02"
    fill_in "cma_case[opened_date(3i)]", with: "10"
    select "CA98 and civil cartels", from: "Case type"
    select "Open", from: "Case state"
    select "Energy", from: "Market sector"

    click_button "Save as draft"

    expect(page.status_code).to eq(422)

    expect(page).to have_css(".elements-error-summary")
    expect(page).to have_css(".elements-error-message")

    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Opened date is not a valid date")
  end

  scenario "with blank opened date and filled out closed date" do
    visit "/cma-cases/new"

    fill_in "Title", with: "Example CMA Case"
    fill_in "Summary", with: "This is the summary of an example CMA case"
    fill_in "Body", with: "Body of text"
    fill_in "cma_case[opened_date(1i)]", with: ""
    fill_in "cma_case[opened_date(2i)]", with: ""
    fill_in "cma_case[opened_date(3i)]", with: ""
    fill_in "cma_case[closed_date(1i)]", with: "2015"
    fill_in "cma_case[closed_date(2i)]", with: "02"
    fill_in "cma_case[closed_date(3i)]", with: "14"
    select "CA98 and civil cartels", from: "Case type"
    select "Open", from: "Case state"
    select "Energy", from: "Market sector"

    click_button "Save as draft"

    expect(page.status_code).to eq(200)

    expect(page).to have_content("Created Example CMA Case")
  end

  scenario "with blank closed date and filled out opened date" do
    visit "/cma-cases/new"

    fill_in "Title", with: "Example CMA Case"
    fill_in "Summary", with: "This is the summary of an example CMA case"
    fill_in "Body", with: "Body of text"
    fill_in "cma_case[opened_date(1i)]", with: "2015"
    fill_in "cma_case[opened_date(2i)]", with: "02"
    fill_in "cma_case[opened_date(3i)]", with: "14"
    fill_in "cma_case[closed_date(1i)]", with: ""
    fill_in "cma_case[closed_date(2i)]", with: ""
    fill_in "cma_case[closed_date(3i)]", with: ""
    select "CA98 and civil cartels", from: "Case type"
    select "Open", from: "Case state"
    select "Energy", from: "Market sector"

    click_button "Save as draft"

    expect(page.status_code).to eq(200)

    expect(page).to have_content("Created Example CMA Case")
  end

  scenario "with blank closed date and opened date" do
    visit "/cma-cases/new"

    fill_in "Title", with: "Example CMA Case"
    fill_in "Summary", with: "This is the summary of an example CMA case"
    fill_in "Body", with: "Body of text"
    fill_in "cma_case[opened_date(1i)]", with: ""
    fill_in "cma_case[opened_date(2i)]", with: ""
    fill_in "cma_case[opened_date(3i)]", with: ""
    fill_in "cma_case[closed_date(1i)]", with: ""
    fill_in "cma_case[closed_date(2i)]", with: ""
    fill_in "cma_case[closed_date(3i)]", with: ""
    select "CA98 and civil cartels", from: "Case type"
    select "Open", from: "Case state"
    select "Energy", from: "Market sector"

    click_button "Save as draft"

    expect(page.status_code).to eq(200)

    expect(page).to have_content("Created Example CMA Case")
  end

  scenario "with a very long title" do
    visit "/cma-cases/new"

    fill_in "Title", with: "At veroeos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident, similique sunt in culpa qui officia deserunt mollitia animi"
    fill_in "Summary", with: "This is the summary of an example CMA case"
    fill_in "Body", with: "## Header#{"\n\nThis is the long body of an example CMA case" * 2}"
    fill_in "cma_case[opened_date(1i)]", with: "2014"
    fill_in "cma_case[opened_date(2i)]", with: "01"
    fill_in "cma_case[opened_date(3i)]", with: "01"

    select "CA98 and civil cartels", from: "Case type"
    select "Open", from: "Case state"
    select "Energy", from: "Market sector"

    click_button "Save as draft"

    expected_sent_payload = {
      "base_path" => "/cma-cases/at-veroeos-et-accusamus-et-iusto-odio-dignissimos-ducimus-qui-blanditiis-praesentium-voluptatum-deleniti-atque-corrupti-quos-dolores-et-quas-molestias-excepturi-sint-occaecati-cupiditate-non-provident-similique-sunt-in-culpa-qui-officia-de",
      "title" => "At veroeos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident, similique sunt in culpa qui officia deserunt mollitia animi",
      "description" => "This is the summary of an example CMA case",
      "document_type" => "cma_case",
      "schema_name" => "specialist_document",
      "publishing_app" => "specialist-publisher",
      "rendering_app" => "government-frontend",
      "locale" => "en",
      "phase" => "live",
      "details" => {
        "body" => [
          {
            "content_type" => "text/govspeak",
            "content" => "## Header\r\n\r\nThis is the long body of an example CMA case\r\n\r\nThis is the long body of an example CMA case",
          },
        ],
        "metadata" => {
          "opened_date" => "2014-01-01",
          "case_type" => "ca98-and-civil-cartels",
          "case_state" => "open",
          "market_sector" => %w[energy],
        },
        "max_cache_time" => 10,
        "headers" => [
          { "text" => "Header", "level" => 2, "id" => "header" },
        ],
        "temporary_update_type" => false,
      },
      "routes" => [{ "path" => "/cma-cases/at-veroeos-et-accusamus-et-iusto-odio-dignissimos-ducimus-qui-blanditiis-praesentium-voluptatum-deleniti-atque-corrupti-quos-dolores-et-quas-molestias-excepturi-sint-occaecati-cupiditate-non-provident-similique-sunt-in-culpa-qui-officia-de", "type" => "exact" }],
      "redirects" => [],
      "update_type" => "major",
      "links" => {
        "finder" => %w[fef4ac7c-024a-4943-9f19-e85a8369a1f3],
      },
    }
    assert_publishing_api_put_content(content_id, expected_sent_payload)

    expect(page.status_code).to eq(200)
    expect(page).to have_content("At veroeos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident, similique sunt in culpa qui officia deserunt mollitia animi")
  end

  scenario "previewing GovSpeak", js: true do
    visit "/cma-cases/new"

    fill_in "Body", with: "$CTA some text $CTA"

    click_link "Preview"

    within(".preview_container") do
      expect(page).to have_content("some text")
      expect(page).not_to have_content("$CTA")
    end

    fill_in "Body", with: "[link text](http://www.example.com)"

    click_link "Preview"

    within(".preview_container") do
      expect(page).to have_content("link text")
      expect(page).not_to have_content("http://www.example.com")
      expect(page).not_to have_content("some text")
    end
  end

  scenario "a draft with the same path as an existing draft" do
    stub_any_publishing_api_put_content.to_raise(
      GdsApi::HTTPErrorResponse.new(422, "Content item base path=/cma-cases/example-document conflicts with content_id=#{content_id} and locale=en"),
    )

    visit "/cma-cases/new"

    fill_in "Title", with: "Example document"
    fill_in "Summary", with: "An explanation"
    fill_in "Body", with: "Some text"
    select "CA98 and civil cartels", from: "Case type"
    select "Open", from: "Case state"
    select "Energy", from: "Market sector"

    click_button "Save as draft"

    expect(page).to have_content("Warning: This document's URL is already used on GOV.UK. You can't publish it until you change the title.")
  end
end
