require 'spec_helper'

RSpec.feature "Creating a CMA case", type: :feature do
  def log_in_as_editor(editor)
    user = FactoryGirl.create(editor)
    GDS::SSO.test_user = user
  end

  def cma_case_content_item
    {
      "content_id" => "4a656f42-35ad-4034-8c7a-08870db7fffe",
      "base_path" => "/cma-cases/example-cma-case",
      "title" => "Example CMA Case",
      "description" => "This is the summary of an example CMA case",
      "format" => "cma_case",
      "publishing_app" => "specialist-publisher",
      "rendering_app" => "specialist-frontend",
      "locale" => "en",
      "phase" => "live",
      "public_updated_at" => "2015-11-23T14:07:47.240Z",
      "details" => {
        "body" => "## Header" + ("\r\n\r\nThis is the long body of an example CMA case" * 10),
        "metadata" => {
          "opened_date" => "2014-01-01",
          "closed_date" => "",
          "case_type" => "ca98-and-civil-cartels",
          "case_state" => "open",
          "market_sector" => ["energy"],
          "outcome_type" => "",
          "document_type" => "cma_case",
        }
      },
      "routes" => [
        {
          "path" => "/cma-cases/example-cma-case",
          "type" => "exact",
        }
      ],
      "redirects" => [],
      "update_type" => "major",
    }
  end

  def cma_case_content_item_links
    {
      "content_id" => "4a656f42-35ad-4034-8c7a-08870db7fffe",
      "links" => {
        "organisations" => ["957eb4ec-089b-4f71-ba2a-dc69ac8919ea"]
      }
    }
  end

  before do
    log_in_as_editor(:cma_editor)

    allow(SecureRandom).to receive(:uuid).and_return("4a656f42-35ad-4034-8c7a-08870db7fffe")
    allow(Time.zone).to receive(:now).and_return("2015-11-23T14:07:47.240Z")

    stub_any_publishing_api_put_content
    stub_any_publishing_api_put_links

    fields = [
      :base_path,
      :content_id,
      :title,
      :public_updated_at,
    ]

    publishing_api_has_fields_for_format('cma_case', [cma_case_content_item], fields)
  end

  scenario "with valid data" do
    visit "/cma-cases/new"

    fill_in "Title", with: "Example CMA Case"
    fill_in "Summary", with: "This is the summary of an example CMA case"
    fill_in "Body", with: "## Header" + ("\n\nThis is the long body of an example CMA case" * 10)
    fill_in "Opened date", with: "2014-01-01"
    select "Energy", from: "Market sector"

    click_button "Save as draft"

    assert_publishing_api_put_content("4a656f42-35ad-4034-8c7a-08870db7fffe", request_json_including(cma_case_content_item))

    expect(page.status_code).to eq(200)
  end

  scenario "with no data" do

    visit "/cma-cases/new"

    click_button "Save as draft"

    expect(page.status_code).to eq(422)

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
    fill_in "Opened date", with: "Not a date"
    select "Energy", from: "Market sector"

    click_button "Save as draft"

    expect(page.status_code).to eq(422)

    expect(page).to have_content("Opened date should be formatted YYYY-MM-DD")
    expect(page).to have_content("Body cannot include invalid Govspeak")
  end
end
