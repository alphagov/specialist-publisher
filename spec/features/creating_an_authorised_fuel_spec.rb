require "spec_helper"

RSpec.feature "Creating an authorised fuel", type: :feature do
  let(:authorised_fuel) { FactoryBot.create(:authorised_fuel) }
  let(:content_id) { authorised_fuel["content_id"] }
  let(:save_button_disable_with_message) { page.find_button("Save as draft")["data-disable-with"] }

  before do
    log_in_as_editor(:gds_editor)
    allow(SecureRandom).to receive(:uuid).and_return(content_id)

    stub_publishing_api_has_content([authorised_fuel], hash_including(document_type: AuthorisedFuel.document_type))
    stub_publishing_api_has_item(authorised_fuel)
    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links
  end

  scenario "visiting the new document page" do
    visit "/authorised-fuels"
    click_link "Add another Authorised fuel"

    expect(page.status_code).to eq(200)
    expect(page.current_path).to eq("/authorised-fuels/new")
  end

  scenario "with valid data" do
    visit "/authorised-fuels/new"

    fill_in "Title", with: "Example authorised fuel"
    fill_in "Summary", with: "This is the summary of an example authorised fuel"
    fill_in "Body", with: "## Header#{"\n\nThis is the long body of an example authorised fuel" * 2}"
    fill_in "Fuel name", with: "Fuel name"
    fill_in "Manufacturer name", with: "Fuel manufacturer name"
    select "Biomass", from: "Fuel type"
    select "England", from: "Country"
    fill_in "Address", with: "123 Rocket Street"

    expect(page).to have_css("div.govspeak-help")
    expect(page).to have_content("To add an attachment, please save the draft first.")
    expect(save_button_disable_with_message).to eq("Saving...")

    click_button "Save as draft"

    expected_sent_payload = {
      "base_path" => "/authorised-fuels/example-authorised-fuel",
      "title" => "Example authorised fuel",
      "description" => "This is the summary of an example authorised fuel",
      "document_type" => "authorised_fuel",
      "schema_name" => "specialist_document",
      "publishing_app" => "specialist-publisher",
      "rendering_app" => "government-frontend",
      "locale" => "en",
      "phase": "live",
      "details" => {
        "body" =>
          [
            {
              "content_type" => "text/govspeak",
              "content" => "## Header\r\n\r\nThis is the long body of an example authorised fuel\r\n\r\nThis is the long body of an example authorised fuel",
            },
          ],
        "metadata" => {
          "authorised_fuel_name" => "Fuel name",
          "authorised_fuel_manufacturer_name" => "Fuel manufacturer name",
          "authorised_fuel_type" => %w[biomass],
          "authorised_fuel_country" => %w[england],
          "authorised_fuel_address" => "123 Rocket Street",
        },
        "max_cache_time" => 10,
        "headers" => [
          { "text" => "Header", "level" => 2, "id" => "header" },
        ],
        "temporary_update_type" => false,
      },
      "routes" => [
        {
          "path" => "/authorised-fuels/example-authorised-fuel",
          "type" => "exact",
        },
      ],
      "redirects" => [],
      "update_type" => "major",
      "links" =>
        {
          "finder" => %w[d3a313e3-6a05-4286-b9c4-5d5cc807f600],
        },
    }

    assert_publishing_api_put_content(content_id, expected_sent_payload)

    expect(page.status_code).to eq(200)
    expect(page).to have_content("Created Example authorised fuel")
    expect(page).to have_content("Bulk published false")
  end

  scenario "with no data" do
    visit "/authorised-fuels/new"

    click_button "Save as draft"

    expect(page.status_code).to eq(422)

    expect(page).to have_css(".elements-error-summary")
    expect(page).to have_css(".form-group.elements-error")
    expect(page).to have_css(".elements-error-message")

    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Title can't be blank")
    expect(page).to have_content("Summary can't be blank")
    expect(page).to have_content("Body can't be blank")
  end

  scenario "with invalid data" do
    visit "/authorised-fuels/new"

    fill_in "Title", with: "Example authorised fuel"
    fill_in "Summary", with: "This is the summary of an example authorised fuel"
    fill_in "Body", with: "<script>alert('hello')</script>"

    click_button "Save as draft"

    expect(page.status_code).to eq(422)

    expect(page).to have_css(".elements-error-summary")
    expect(page).to have_css(".elements-error-message")

    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Body cannot include invalid Govspeak")
    expect(page).to have_content("Authorised fuel country can't be blank")
  end
end
