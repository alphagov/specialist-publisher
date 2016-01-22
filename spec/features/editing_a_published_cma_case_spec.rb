require 'spec_helper'

RSpec.feature "Editing a published CMA case", type: :feature do
  def log_in_as_editor(editor)
    user = FactoryGirl.create(editor)
    GDS::SSO.test_user = user
  end

  def published_cma_case_content_item
    {
      "content_id" => "4a656f42-35ad-4034-8c7a-08870db7fffe",
      "base_path" => "/cma-cases/example-cma-case",
      "title" => "Example CMA Case",
      "description" => "This is the summary of a published example CMA case",
      "format" => "specialist_document",
      "publishing_app" => "specialist-publisher",
      "rendering_app" => "specialist-frontend",
      "locale" => "en",
      "phase" => "live",
      "public_updated_at" => "2015-11-23T14:07:47+00:00",
      "publication_state" => "live",
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
            "public_timestamp" => "2015-11-23T14:07:47+00:00",
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
      "update_type" => "major",
    }
  end

  def redrafted_cma_case_content_item
    {
      "content_id" => "4a656f42-35ad-4034-8c7a-08870db7fffe",
      "base_path" => "/cma-cases/example-cma-case",
      "title" => "Example CMA Case",
      "description" => "This is the summary of a redrafted example CMA case",
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

    stub_any_publishing_api_put_content
    stub_any_publishing_api_put_links

    fields = [
      :base_path,
      :content_id,
      :title,
      :public_updated_at,
      :details,
      :description,
    ]

    publishing_api_has_fields_for_format('specialist_document', [published_cma_case_content_item], fields)

    publishing_api_has_item(published_cma_case_content_item)

    Timecop.freeze(Time.parse("2015-12-03 16:59:13 UTC"))
  end

  after do
    Timecop.return
  end

  scenario "with a minor update" do
    changed_json = published_cma_case_content_item.merge({
      "title" => "Minor update title",
      "description" => "Minor update summary",
      "update_type" => "minor",
    })

    changed_json.delete("publication_state")

    visit "/cma-cases/4a656f42-35ad-4034-8c7a-08870db7fffe"

    click_link "Edit document"

    fill_in "Title", with: "Minor update title"
    fill_in "Summary", with: "Minor update summary"
    fill_in "Body", with: "## Header" + ("\n\nThis is the long body of an example CMA case" * 10)
    fill_in "Opened date", with: "2014-01-01"

    choose("cma_case_update_type_minor")

    click_button "Save as draft"

    assert_publishing_api_put_content("4a656f42-35ad-4034-8c7a-08870db7fffe", request_json_including(changed_json))
    expect(changed_json["content_id"]).to eq("4a656f42-35ad-4034-8c7a-08870db7fffe")
    expect(changed_json["public_updated_at"]).to eq("2015-11-23T14:07:47+00:00")

    expect(page.status_code).to eq(200)
    expect(page).to have_content("Updated Minor update title")
  end

  scenario "with a major update" do
    changed_json = published_cma_case_content_item.merge({
      "title" => "Major update title",
      "description" => "Major update summary",
      "public_updated_at" => "2015-12-03T16:59:13+00:00",
      "update_type" => "major",
    })

    changed_json["details"]["change_history"] << { "public_timestamp" => "2015-12-03T16:59:13+00:00", "note" => "This is a change note." }

    changed_json.delete("publication_state")

    visit "/cma-cases/4a656f42-35ad-4034-8c7a-08870db7fffe"

    click_link "Edit document"

    fill_in "Title", with: "Major update title"
    fill_in "Summary", with: "Major update summary"
    fill_in "Body", with: "## Header" + ("\n\nThis is the long body of an example CMA case" * 10)
    fill_in "Opened date", with: "2014-01-01"

    choose("cma_case_update_type_major")

    fill_in "Change note", with: "This is a change note."

    click_button "Save as draft"

    assert_publishing_api_put_content("4a656f42-35ad-4034-8c7a-08870db7fffe", request_json_including(changed_json))
    expect(changed_json["content_id"]).to eq("4a656f42-35ad-4034-8c7a-08870db7fffe")
    expect(changed_json["public_updated_at"]).to eq("2015-12-03T16:59:13+00:00")

    expect(page.status_code).to eq(200)
    expect(page).to have_content("Updated Major update title")
  end
end
