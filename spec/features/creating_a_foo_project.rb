require "spec_helper"

RSpec.feature "Creating an FOO project", type: :feature do
  let(:foo_project) { FactoryBot.create(:foo_project) }
  let(:content_id) { foo_project["content_id"] }

  before do
    log_in_as_editor(:foo_editor)
    stub_publishing_api_has_content([foo_project], hash_including(document_type: FooProject.document_type))
    stub_publishing_api_has_item(foo_project)
    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links
  end

  scenario "visiting the new project page" do
    visit "/foo-projects"
    click_link "Add another FOO Project"
    expect(page.status_code).to eq(200)
    expect(page.current_path).to eq("/foo-projects/new")
  end

  scenario "creating a project with valid data" do
    allow(SecureRandom).to receive(:uuid).and_return(content_id)

    visit "/foo-projects/new"

    fill_in "Title", with: "Example FOO Project"
    fill_in "Summary", with: "This is the summary of an example FOO project"
    fill_in "Body", with: "## Header#{"\n\nThis is the long body of an example FOO project" * 2}"
    fill_in "[foo_project]foo_project_opened_date(1i)", with: "2014"
    fill_in "[foo_project]foo_project_opened_date(2i)", with: "01"
    fill_in "[foo_project]foo_project_opened_date(3i)", with: "01"
    select "Annual report", from: "Project type"

    expect(page).to have_css("div.govspeak-help")
    expect(page).to have_content("To add an attachment, please save the draft first.")

    save_button_disable_with_message = page.find_button("Save as draft")["data-disable-with"]
    expect(save_button_disable_with_message).to eq("Saving...")

    click_button "Save as draft"

    expected_sent_payload = {
      "base_path" => "/foo-projects/example-FOO-project",
      "title" => "Example FOO Project",
      "description" => "This is the summary of an example FOO project",
      "document_type" => "foo_project",
      "schema_name" => "specialist_document",
      "publishing_app" => "specialist-publisher",
      "rendering_app" => "government-frontend",
      "locale" => "en",
      "phase" => "live",
      "details" => {
        "body" => [
          {
            "content_type" => "text/govspeak",
            "content" => "## Header\r\n\r\nThis is the long body of an example FOO project\r\n\r\nThis is the long body of an example FOO project",
          },
        ],
        "metadata" => {
          "foo_project_opened_date" => "2014-01-01",
          "foo_project_type" => "annual-report",
          "foo_project_state" => "open",
        },
        "max_cache_time" => 10,
        "temporary_update_type" => false,
        "headers" => [
          { "text" => "Header", "level" => 2, "id" => "header" },
        ],
      },
      "routes" => [{ "path" => "/foo-projects/example-foo-project", "type" => "exact" }],
      "redirects" => [],
      "update_type" => "major",
      "links" => {
        "finder" => %w[4e4e33ff-271a-468a-b7a8-92d25f3f8ac0],
      },
    }

    assert_publishing_api_put_content(content_id, expected_sent_payload)

    expect(page.status_code).to eq(200)
    expect(page).to have_content("Created Example FOO Project")
    expect(page).to have_content("Bulk published false")
  end

  scenario "creating a project with with no data" do
    visit "/foo-projects/new"
    expect(page.status_code).to eq(200)
    click_button "Save as draft"

    expect(page.status_code).to eq(422)
    expect(page).to have_content("Title can't be blank")
    expect(page).to have_content("Summary can't be blank")
    expect(page).to have_content("Body can't be blank")
  end

  scenario "creating a project with with invalid data" do
    visit "/foo-projects/new"
    expect(page.status_code).to eq(200)

    fill_in "Title", with: "Example FOO Project"
    fill_in "Summary", with: "This is the summary of an example FOO project"
    fill_in "Body", with: "<script>alert('hello')</script>"
    fill_in "[foo_project]foo_project_opened_date(1i)", with: "2014"
    fill_in "[foo_project]foo_project_opened_date(2i)", with: "01"
    fill_in "[foo_project]foo_project_opened_date(3i)", with: "01"
    fill_in "[foo_project]foo_project_closed_date(1i)", with: "2013"
    fill_in "[foo_project]foo_project_closed_date(2i)", with: "01"
    fill_in "[foo_project]foo_project_closed_date(3i)", with: "01"

    click_button "Save as draft"

    expect(page.status_code).to eq(422)
    expect(page).to have_content("Body cannot include invalid Govspeak")
    expect(page).to have_content("Opened date must be before closed date")
  end
end
