require "spec_helper"

RSpec.feature "Editing a CMA case", type: :feature do
  let(:cma_case) do
    FactoryBot.create(:cma_case, title: "Example CMA Case", state_history: { "1" => "draft" })
  end
  let(:content_id) { cma_case["content_id"] }
  let(:locale) { cma_case["locale"] }
  let(:save_button_disable_with_message) { page.find_button("Save")["data-disable-with"] }

  before do
    Timecop.freeze(Time.zone.parse("2015-12-03T16:59:13+00:00"))
    log_in_as_design_system_editor(:cma_editor)

    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links

    stub_publishing_api_has_content([cma_case], hash_including(document_type: CmaCase.document_type))
    stub_publishing_api_has_item(cma_case)

    visit "/cma-cases/#{content_id}:#{locale}"
    click_link "Edit document"
  end

  after do
    Timecop.return
  end

  scenario "successful update of a draft" do
    updated_cma_case = cma_case.deep_merge(
      "title" => "Changed title",
      "description" => "Changed summary",
      "base_path" => "/cma-cases/changed-title",
      "routes" => [{ "path" => "/cma-cases/changed-title", "type" => "exact" }],
      "details" => {
        "metadata" => {
          "opened_date" => "2014-01-01",
          "market_sector" => %w[energy],
        },
        "body" => [
          {
            "content_type" => "text/govspeak",
            "content" => "## Header#{"\r\n\r\nThis is the long body of an example CMA case" * 2}",
          },
        ],
        "headers" => [{
          "text" => "Header",
          "level" => 2,
          "id" => "header",
        }],
      },
    )
    expected_sent_payload = write_payload(updated_cma_case)

    fill_in "Title", with: "Changed title"
    fill_in "Summary", with: "Changed summary"
    fill_in "Body", with: "## Header#{"\n\nThis is the long body of an example CMA case" * 2}"
    fill_in "cma_case[opened_date(1i)]", with: "2014"
    fill_in "cma_case[opened_date(2i)]", with: "01"
    fill_in "cma_case[opened_date(3i)]", with: "01"
    select "Energy", from: "Market sector"

    expect(page).to have_css("div.govspeak-help")
    expect(page).to have_content("Add attachment")

    click_button "Save"

    assert_publishing_api_put_content(content_id, expected_sent_payload)

    expect(page.status_code).to eq(200)
    expect(page).to have_content("Updated Changed title")
  end

  context "a published case" do
    let(:cma_case) do
      FactoryBot.create(
        :cma_case,
        :published,
        title: "Example CMA Case",
        description: "Summary with a typox",
        state_history: { "1" => "draft", "2" => "published" },
        details: {
          "body" => [
            { "content_type" => "text/govspeak", "content" => "A body" },
          ],
          "metadata" => {
            "bulk_published" => true,
          },
        },
      ).tap { |payload| payload["details"].delete("headers") }
    end

    scenario "a major update adds to the change history" do
      fill_in "Title", with: "Changed title"
      choose "Major"
      fill_in "Change note", with: "This is a change note."
      click_button "Save"

      changed_json = {
        "title" => "Changed title",
        "update_type" => "major",
        "change_note" => "This is a change note.",
      }
      assert_publishing_api_put_content(content_id, request_json_includes(changed_json))
    end

    scenario "a minor update doesn't add to the change history" do
      fill_in "Summary", with: "Summary without a typo"

      choose "Minor"
      click_button "Save"

      changed_json = {
        "description" => "Summary without a typo",
        "update_type" => "minor",
      }
      assert_publishing_api_put_content(content_id, request_json_includes(changed_json))
    end

    scenario "date values display" do
      visit "/cma-cases/#{content_id}:#{locale}/edit"

      expect(page).to have_field("cma_case[opened_date(1i)]", with: "2014")
      expect(page).to have_field("cma_case[opened_date(2i)]", with: "1")
      expect(page).to have_field("cma_case[opened_date(3i)]", with: "1")
      expect(page).to have_field("cma_case[closed_date(1i)]", with: "2015")
      expect(page).to have_field("cma_case[closed_date(2i)]", with: "1")
      expect(page).to have_field("cma_case[closed_date(3i)]", with: "1")
    end

    context "when a document already has a change note" do
      let(:cma_case) do
        FactoryBot.create(
          :cma_case,
          update_type: "major",
          first_published_at: "2016-01-01",
          state_history: { "3" => "draft", "2" => "published", "1" => "superseded" },
        )
      end

      it "creates new change note" do
        update_type = find_field("cma_case[update_type]", with: "major")
        expect(update_type).to be_checked

        fill_in "Change note", with: "New change note"

        click_button "Save"

        assert_publishing_api_put_content(
          content_id,
          lambda { |request|
            payload = JSON.parse(request.body)
            change_note = payload.fetch("change_note")
            expect(change_note).to eq "New change note"
          },
        )
      end
    end

    context "a bulk published document" do
      scenario "the 'bulk published' flag isn't lost after an update" do
        expect(cma_case["details"]["metadata"]["bulk_published"]).to be_truthy
        fill_in "Summary", with: "An updated summary"

        choose "Minor"
        click_button "Save"

        changed_json = {
          "description" => "An updated summary",
          "update_type" => "minor",
        }
        assert_publishing_api_put_content(content_id, request_json_includes(changed_json))
        expect(page).to have_content("Bulk published true")
      end
    end
  end

  scenario "attempted update of a draft with invalid data" do
    fill_in "Title", with: "Changed title"
    fill_in "Summary", with: "Changed summary"
    fill_in "Body", with: "<script>alert('hello')</script>"
    fill_in "cma_case[opened_date(1i)]", with: "not"
    fill_in "cma_case[opened_date(2i)]", with: "a"
    fill_in "cma_case[opened_date(3i)]", with: "date"
    select "CA98 and civil cartels", from: "Case type"
    select "Open", from: "Case state"
    select "Energy", from: "Market sector"

    click_button "Save"

    expect(page).to have_css(".govuk-error-summary")
    expect(page).to have_css(".govuk-error-message")

    expect(page).to have_content("Opened date is not a valid date")
    expect(page).to have_content("Body cannot include invalid Govspeak")
    expect(page).to have_content("There is a problem")

    expect(page.status_code).to eq(422)
  end

  context "an unpublished document" do
    let(:cma_case) do
      FactoryBot.create(
        :cma_case,
        :unpublished,
        title: "Example CMA Case",
        details: {},
        state_history: { "1" => "published", "2" => "unpublished", "3" => "draft" },
      )
    end

    scenario "showing the update type radio buttons" do
      within(".edit_document") do
        expect(page).to have_content("Only use for minor changes like fixes to typos, links, GOV.UK style or metadata.")
        expect(page).to have_content("This will notify subscribers to ")
        expect(page).to have_content("Minor")
        expect(page).to have_content("Major")
      end
    end

    scenario "insisting that an update type is chosen" do
      click_button "Save"

      expect(page).to have_content("There is a problem")
      expect(page).to have_content("Update type can't be blank")

      expect(page.status_code).to eq(422)
    end

    scenario "updating the title does not update the base path" do
      fill_in "Title", with: "New title"
      choose "Minor"
      click_button "Save"
      changed_json = {
        "title" => "New title",
        "update_type" => "minor",
        "base_path" => "/cma-cases/example-document",
      }
      assert_publishing_api_put_content(content_id, request_json_includes(changed_json))
    end
  end

  context "a draft document" do
    scenario "not showing the update type radio buttons" do
      within(".edit_document") do
        expect(page).not_to have_content("Only use for minor changes like fixes to typos, links, GOV.UK style or metadata.")
        expect(page).not_to have_content("This will notify subscribers to ")
        expect(page).not_to have_content("Minor")
        expect(page).not_to have_content("Major")
      end
    end

    scenario "saving the document without an update type" do
      click_button "Save"
      expect(page).to have_content("Updated Example CMA Case")
      expect(page.status_code).to eq(200)
    end
  end
end
