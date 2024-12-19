require "spec_helper"

RSpec.feature "Creating a DRCF digital markets research", type: :feature do
  let(:drcf_digital_markets_research) { FactoryBot.create(:drcf_digital_markets_research) }
  let(:content_id) { drcf_digital_markets_research["content_id"] }
  let(:save_button_disable_with_message) { page.find_button("Save as draft")["data-disable-with"] }

  before do
    log_in_as_editor(:drcf_digital_markets_research_editor)
    allow(SecureRandom).to receive(:uuid).and_return(content_id)

    stub_publishing_api_has_content([drcf_digital_markets_research], hash_including(document_type: DrcfDigitalMarketsResearch.document_type))
    stub_publishing_api_has_item(drcf_digital_markets_research)
    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links
  end

  scenario "visiting the new research page" do
    visit "/drcf-digital-markets-researches"
    click_link "Add another DRCF digital markets research"
    expect(page.status_code).to eq(200)
    expect(page.current_path).to eq("/drcf-digital-markets-researches/new")
  end

  scenario "creating the new DRCF digital markets research with no data" do
    visit "/drcf-digital-markets-researches/new"

    click_button "Save as draft"

    expect(page.status_code).to eq(422)

    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Title can't be blank")
    expect(page).to have_content("Summary can't be blank")
    expect(page).to have_content("Body can't be blank")
    expect(page).to have_content("Digital market research category can't be blank")
    expect(page).to have_content("Digital market research publisher can't be blank")
    expect(page).to have_content("Digital market research area can't be blank")
    expect(page).to have_content("Digital market research topic can't be blank")
    expect(page).to have_content("Digital market research publish date can't be blank")
  end

  scenario "creating the new DRCF digital markets research with valid data" do
    visit "/drcf-digital-markets-researches/new"

    fill_in "Title", with: "Example DRCF digital markets research"
    fill_in "Summary", with: "This is the summary of an example DRCF digital markets research"
    fill_in "Body", with: "## Header#{"\n\nThis is the long body of an example DRCF digital markets research" * 2}"
    fill_in "[drcf_digital_markets_research]digital_market_research_publish_date(1i)", with: "2022"
    fill_in "[drcf_digital_markets_research]digital_market_research_publish_date(2i)", with: "02"
    fill_in "[drcf_digital_markets_research]digital_market_research_publish_date(3i)", with: "02"
    select "Ad hoc research", from: "Category"
    select "Gambling Commission", from: "Original publisher"
    select "Media and entertainment", from: "Research area"
    select "Future connectivity", from: "Research topic"

    expect(page).to have_css("div.govspeak-help")
    expect(page).to have_content("To add an attachment, please save the draft first.")
    expect(save_button_disable_with_message).to eq("Saving...")

    click_button "Save as draft"

    expected_sent_payload = {
      "base_path" => "/find-digital-market-research/example-drcf-digital-markets-research",
      "title" => "Example DRCF digital markets research",
      "description" => "This is the summary of an example DRCF digital markets research",
      "document_type" => "drcf_digital_markets_research",
      "schema_name" => "specialist_document",
      "publishing_app" => "specialist-publisher",
      "rendering_app" => "government-frontend",
      "locale" => "en",
      "phase" => "live",
      "details" => {
        "body" => [
          {
            "content_type" => "text/govspeak",
            "content" => "## Header\r\n\r\nThis is the long body of an example DRCF digital markets research\r\n\r\nThis is the long body of an example DRCF digital markets research",
          },
        ],
        "metadata" => {
          "digital_market_research_category" => "ad-hoc-research",
          "digital_market_research_publisher" => %w[gambling-commission],
          "digital_market_research_area" => %w[media-and-entertainment],
          "digital_market_research_topic" => %w[future-connectivity],
          "digital_market_research_publish_date" => "2022-02-02",
        },
        "max_cache_time" => 10,
        "headers" => [
          { "text" => "Header", "level" => 2, "id" => "header" },
        ],
        "temporary_update_type" => false,
      },
      "routes" => [{ "path" => "/find-digital-market-research/example-drcf-digital-markets-research", "type" => "exact" }],
      "redirects" => [],
      "update_type" => "major",
      "links" => {
        "finder" => %w[380def5e-bed2-4501-967e-334767ac270d],
      },
    }

    assert_publishing_api_put_content(content_id, expected_sent_payload)

    expect(page.status_code).to eq(200)
    expect(page).to have_content("Created Example DRCF digital markets research")
    expect(page).to have_content("Bulk published false")
  end

  scenario "creating the new DRCF digital markets research with an invalid date" do
    visit "/drcf-digital-markets-researches/new"

    fill_in "Title", with: "Example DRCF digital markets research"
    fill_in "Summary", with: "This is the summary of an example DRCF digital markets research"
    fill_in "Body", with: "## Header#{"\n\nThis is the long body of an example DRCF digital markets research" * 2}"
    fill_in "[drcf_digital_markets_research]digital_market_research_publish_date(1i)", with: "2021"
    fill_in "[drcf_digital_markets_research]digital_market_research_publish_date(2i)", with: "02"
    fill_in "[drcf_digital_markets_research]digital_market_research_publish_date(3i)", with: "31"
    select "Ad hoc research", from: "Category"
    select "Gambling Commission", from: "Original publisher"
    select "Media and entertainment", from: "Research area"
    select "Future connectivity", from: "Research topic"

    click_button "Save as draft"

    expect(page.status_code).to eq(422)

    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Digital market research publish date is not a valid date")
  end

  scenario "creating the new DRCF digital markets research with invalid data" do
    visit "/drcf-digital-markets-researches/new"

    fill_in "Title", with: "Example DRCF digital markets research"
    fill_in "Summary", with: "This is the summary of an example DRCF digital markets research"
    fill_in "Body", with: "<script>alert('hello')</script>"

    click_button "Save as draft"

    expect(page.status_code).to eq(422)

    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Body cannot include invalid Govspeak")
  end
end
