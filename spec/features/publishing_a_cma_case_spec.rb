require 'spec_helper'

RSpec.feature "Publishing a CMA case", type: :feature do
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
      "description" => "This is the summary of an example CMA case",
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

  let(:cma_case) {
    Payloads.cma_case_content_item(
      "public_updated_at" => "2015-11-16T11:53:30+00:00",
      "need_ids" => [],
      "publication_state" => "draft",
    )
  }
  let(:content_id) { cma_case['content_id'] }

  let(:fields) { [:base_path, :content_id, :public_updated_at, :title, :publication_state] }
  let(:page_number) { 1 }
  let(:per_page) { 50 }

  def minor_update_item
    cma_case.merge(
      "title" => "Minor Update Case",
      "update_type" => "minor"
    )
  end

  def live_item
    cma_case.merge(
      "title" => "Live Item",
      "publication_state" => "live"
    )
  end

  def withdrawn_item
    cma_case.merge(
      "title" => "Withdrawn Item",
      "publication_state" => "withdrawn"
    )
  end

  before do
    log_in_as_editor(:cma_editor)

    publishing_api_has_content([cma_case, minor_update_item, live_item, withdrawn_item], document_type: CmaCase.publishing_api_document_type, fields: fields, page: page_number, per_page: per_page)
    publishing_api_has_content([cma_org_content_item], document_type: 'organisation', fields: [:base_path, :content_id])

    publishing_api_has_item(cma_case)

    stub_publishing_api_publish(content_id, {})
    stub_any_rummager_post_with_queueing_enabled
    email_alert_api_accepts_alert
  end

  scenario "from the index" do
    publishing_api_has_item(cma_case)

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
    assert_email_alert_sent
  end

  scenario "alerts should not be sent when update type is minor" do
    publishing_api_has_item(minor_update_item)

    visit "/cma-cases"

    expect(page.status_code).to eq(200)

    click_link "Minor Update Case"

    expect(page.status_code).to eq(200)
    expect(page).to have_content("Minor Update Case")

    click_button "Publish"
    expect(page.status_code).to eq(200)
    expect(page).to have_content("Published Minor Update Case")

    assert_publishing_api_publish(content_id)

    assert_not_requested(:post, Plek.current.find('email-alert-api') + "/notifications")
  end

  scenario "when content item is live, there will be no publish button" do
    publishing_api_has_item(live_item)

    visit "/cma-cases"

    expect(page.status_code).to eq(200)

    click_link "Live Item"

    expect(page).not_to have_selector(:button, 'Publish')
    expect(page).to have_content("There are no changes to publish.")
  end

  scenario "when content item is withdrawn, there will be a publish button" do
    publishing_api_has_item(withdrawn_item)

    visit "/cma-cases"

    expect(page.status_code).to eq(200)

    click_link "Withdrawn Item"

    expect(page).to have_selector(:button, 'Publish')
    expect(page).not_to have_content("There are no changes to publish.")
  end
end
