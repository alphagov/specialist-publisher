require 'spec_helper'

RSpec.feature "Publishing a CMA case", type: :feature do

  def log_in_as_editor(editor)
    user = FactoryGirl.create(editor)
    GDS::SSO.test_user = user
  end

  def content_id
    "4a656f42-35ad-4034-8c7a-08870db7fffe"
  end

  def cma_case_content_item
    {
      "content_id" => content_id,
      "base_path" => "/cma-cases/example-cma-case",
      "title" => "Example CMA Case",
      "description" => "This is the summary of example CMA case",
      "format" => "cma_case",
      "publishing_app" => "specialist-publisher",
      "rendering_app" => "specialist-frontend",
      "locale" => "en",
      "phase" => "live",
      "public_updated_at" => "2015-11-16T11:53:30.000+00:00",
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
      "links" => {
        "organisations" => ["957eb4ec-089b-4f71-ba2a-dc69ac8919ea"]
      }
    }
  end

  before do
    log_in_as_editor(:cma_editor)

    fields = [
      :base_path,
      :content_id,
      :title,
      :public_updated_at,
    ]

    publishing_api_has_fields_for_format('cma_case', [cma_case_content_item], fields)

    publishing_api_has_item(cma_case_content_item)

    stub_publishing_api_publish(content_id, {})
  end

  scenario "from the index" do
    visit "/cma-cases"

    expect(page.status_code).to eq(200)

    click_link "Example CMA Case"

    expect(page.status_code).to eq(200)
    expect(page).to have_content("Example CMA Case")

    click_button "Publish"

    assert_publishing_api_publish(content_id)
  end

end
