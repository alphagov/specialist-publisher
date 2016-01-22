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
      "format" => "specialist_document",
      "publishing_app" => "specialist-publisher",
      "rendering_app" => "specialist-frontend",
      "locale" => "en",
      "phase" => "live",
      "public_updated_at" => "2015-11-16T11:53:30+00:00",
      "details" => {
        "body" => "## Header" + ("\r\n\r\nThis is the long body of an example CMA case" * 10),
        "metadata" => {
          "opened_date" => "2014-01-01",
          "case_type" => "ca98-and-civil-cartels",
          "case_state" => "open",
          "market_sector" => ["energy"],
          "document_type" => "cma_case",
        },
        "change_history" => [
          {
            "public_timestamp" => "2015-11-16T11:53:30+00:00",
            "note" => "First published."
          }
        ]
      },
      "routes" => [
        {
          "path" => "/cma-cases/example-cma-case",
          "type" => "exact",
        }
      ],
      "redirects" => [],
      "need_ids" => [],
      "update_type" => "major",
      "phase" => "live",
      "publication_state" => "live",
      "links" => {
        "organisations" => ["957eb4ec-089b-4f71-ba2a-dc69ac8919ea"]
      }
    }
  end

  def cma_org_content_item
    {
      "base_path" => "/government/organisations/competition-and-markets-authority",
      "content_id" => "957eb4ec-089b-4f71-ba2a-dc69ac8919ea",
      "title" => "Competition and Markets Authority",
      "format" => "placeholder_organisation",
      "need_ids" => [],
      "locale" => "en",
      "updated_at" => "2015-10-26T09:21:17.645Z",
      "public_updated_at" => "2015-03-10T16:23:14.000+00:00",
      "phase" => "live",
      "analytics_identifier" => "D550",
      "links" => {
        "available_translations" => [
          {
            "content_id" => "957eb4ec-089b-4f71-ba2a-dc69ac8919ea",
            "title" => "Competition and Markets Authority",
            "base_path" => "/government/organisations/competition-and-markets-authority",
            "description" => nil,
            "api_url" => "https://www.gov.uk/api/content/government/organisations/competition-and-markets-authority",
            "web_url" => "https://www.gov.uk/government/organisations/competition-and-markets-authority",
            "locale" => "en"
          }
        ]
      },
      "description" => nil,
      "details" => {}
    }
  end

  def indexable_attributes
    {
      "title" => "Example CMA Case",
      "description" => "This is the summary of example CMA case",
      "link" => "/cma-cases/example-cma-case",
      "indexable_content" => "## Header" + ("\r\n\r\nThis is the long body of an example CMA case" * 10),
      "public_timestamp" => "2015-11-16T11:53:30+00:00",
      "opened_date" => "2014-01-01",
      "closed_date" => nil,
      "case_type" => "ca98-and-civil-cartels",
      "case_state" => "open",
      "market_sector" => ["energy"],
      "outcome_type" => nil,
      "organisations" => ["competition-and-markets-authority"],
    }
  end

  before do
    log_in_as_editor(:cma_editor)

    fields = [
      :base_path,
      :content_id,
      :title,
      :public_updated_at,
      :details,
      :description,
    ]

    publishing_api_has_fields_for_format('specialist_document', [cma_case_content_item], fields)
    publishing_api_has_fields_for_format('organisation', [cma_org_content_item], [:base_path, :content_id])

    publishing_api_has_item(cma_case_content_item)

    stub_publishing_api_publish(content_id, {})
    stub_any_rummager_post
  end

  scenario "from the index" do
    visit "/cma-cases"

    expect(page.status_code).to eq(200)

    click_link "Example CMA Case"

    expect(page.status_code).to eq(200)
    expect(page).to have_content("Example CMA Case")

    click_button "Publish"

    expect(page.status_code).to eq(200)
    expect(page).to have_content("Published Example CMA Case")

    assert_publishing_api_publish(content_id)
    assert_rummager_posted_item(indexable_attributes)
  end

end
