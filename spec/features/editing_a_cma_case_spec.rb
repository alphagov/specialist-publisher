require "spec_helper"

RSpec.feature "Editing a CMA case", type: :feature do
  let(:cma_case) do
    FactoryBot.create(:cma_case, title: "Example CMA Case", state_history: { "1" => "draft" })
  end
  let(:content_id) { cma_case["content_id"] }
  let(:locale) { cma_case["locale"] }
  let(:save_button_disable_with_message) { page.find_button("Save as draft")["data-disable-with"] }

  before do
    Timecop.freeze(Time.zone.parse("2015-12-03T16:59:13+00:00"))
    log_in_as_editor(:cma_editor)

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
    fill_in "[cma_case]opened_date(1i)", with: "2014"
    fill_in "[cma_case]opened_date(2i)", with: "01"
    fill_in "[cma_case]opened_date(3i)", with: "01"
    select "Energy", from: "Market sector"

    expect(page).to have_css("div.govspeak-help")
    expect(page).to have_content("Add attachment")
    expect(save_button_disable_with_message).to eq("Saving...")

    click_button "Save as draft"

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
      click_button "Save as draft"

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
      click_button "Save as draft"

      changed_json = {
        "description" => "Summary without a typo",
        "update_type" => "minor",
      }
      assert_publishing_api_put_content(content_id, request_json_includes(changed_json))
    end

    scenario "date values display" do
      visit "/cma-cases/#{content_id}:#{locale}/edit"

      expect(page).to have_field("cma_case_opened_date_year", with: "2014")
      expect(page).to have_field("cma_case_opened_date_month", with: "01")
      expect(page).to have_field("cma_case_opened_date_day", with: "01")
      expect(page).to have_field("cma_case_closed_date_year", with: "2015")
      expect(page).to have_field("cma_case_closed_date_month", with: "01")
      expect(page).to have_field("cma_case_closed_date_day", with: "01")
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
        radio_major = find_field("cma_case_update_type_major")
        expect(radio_major).to be_checked

        fill_in "Change note", with: "New change note"

        click_button "Save as draft"

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
        click_button "Save as draft"

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
    fill_in "[cma_case]opened_date(1i)", with: "not"
    fill_in "[cma_case]opened_date(2i)", with: "a"
    fill_in "[cma_case]opened_date(3i)", with: "date"
    select "Energy", from: "Market sector"

    click_button "Save as draft"

    expect(page).to have_css(".elements-error-summary")
    expect(page).to have_css(".elements-error-message")

    expect(page).to have_content("Opened date is not a valid date")
    expect(page).to have_content("Body cannot include invalid Govspeak")
    expect(page).to have_content("There is a problem")

    expect(page.status_code).to eq(422)
  end

  context "with attachments" do
    let(:asset_manager_response) do
      {
        id: "http://asset-manager.dev.gov.uk/assets/another_image_id",
        file_url: "http://assets-origin.dev.gov.uk/media/56c45553759b740609000000/cma_case_image.jpg",
      }
    end
    let(:existing_attachments) do
      [
        {
          "attachment_type" => "file",
          "id" => "77f2d40e-3853-451f-9ca3-a747e8402e34",
          "content_id" => "77f2d40e-3853-451f-9ca3-a747e8402e34",
          "url" => "https://assets.digital.cabinet-office.gov.uk/media/513a0efbed915d425e000002/asylum-support-image.jpg",
          "content_type" => "application/jpg",
          "title" => "asylum report image title",
          "created_at" => "2015-12-03T16:59:13+00:00",
          "updated_at" => "2015-12-03T16:59:13+00:00",
        },
        {
          "attachment_type" => "file",
          "id" => "ec3f6901-4156-4720-b4e5-f04c0b152141",
          "content_id" => "ec3f6901-4156-4720-b4e5-f04c0b152141",
          "url" => "https://assets.digital.cabinet-office.gov.uk/media/513a0efbed915d425e000002/asylum-support-pdf.pdf",
          "content_type" => "application/pdf",
          "title" => "asylum report pdf title",
          "created_at" => "2015-12-03T16:59:13+00:00",
          "updated_at" => "2015-12-03T16:59:13+00:00",
        },
      ]
    end

    before do
      stub_request(:post, "#{Plek.find('asset-manager')}/assets")
        .to_return(body: asset_manager_response.to_json, status: 201)
    end

    %i[draft published].each do |publication_state|
      let(:cma_case) do
        FactoryBot.create(
          :cma_case,
          publication_state,
          title: "Example CMA Case",
          details: { "attachments" => existing_attachments },
        )
      end

      # TODO: this test isn't actually checking that the attachment has been added
      scenario "adding an attachment to a #{publication_state} CMA case" do
        updated_cma_case = cma_case.deep_merge(
          "update_type" => "minor",
          "details" => {
            "body" => [
              {
                "content_type" => "text/govspeak",
                "content" => "[InlineAttachment:asylum-support-image.jpg]",
              },
            ],
          },
        )

        expect(page).not_to have_link("Delete", href: "/")
        click_link "Add attachment"
        expect(page.status_code).to eq(200)

        expect(page).to have_link("Your documents", href: "/cma-cases")
        fill_in "Title", with: "New cma case image"
        page.attach_file("attachment_file", "spec/support/images/cma_case_image.jpg")

        click_button "Save attachment"

        expect(page.status_code).to eq(200)
        expect(page).to have_content("Editing Example CMA Case")
        expect(page).to have_content("New cma case image")
        expect(page).to have_content("[InlineAttachment:asylum-support-image.jpg]")

        fill_in "Body", with: "[InlineAttachment:asylum-support-image.jpg]"
        choose "Minor"

        stub_publishing_api_has_item(updated_cma_case)

        click_button "Save as draft"

        update_govspeak_body_in_payload(updated_cma_case, existing_attachments)

        assert_publishing_api_put_content(content_id, write_payload(updated_cma_case))

        expect(page).to have_content("[InlineAttachment:asylum-support-image.jpg]")
      end

      scenario "editing an attachment on a #{publication_state} CMA case" do
        # this is to force app to not update asset manager on only-name edits
        stub_request(:post, "#{Plek.find('asset-manager')}/assets")
          .with(body: %r{.*})
          .to_return(body: asset_manager_response.to_json, status: 500)

        expect(page).to have_button("delete")
        find(".attachments").first(:link, "edit").click
        expect(page.status_code).to eq(200)
        expect(find("#attachment_title").value).to eq("asylum report image title")

        fill_in "Title", with: "Updated cma case image"

        click_button("Save attachment")

        expect(page.status_code).to eq(200)
        expect(page).to have_content("Editing Example CMA Case")
      end

      context "when the document is in an invalid state" do
        let(:cma_case) { FactoryBot.create(:cma_case, details: { body: "" }) }

        scenario "successfully adding an attachment to the invalid document" do
          click_link "Add attachment"

          fill_in "Title", with: "Some title"
          page.attach_file("attachment_file", "spec/support/images/cma_case_image.jpg")
          click_button "Save attachment"

          expect(page.status_code).to eq(200)
          expect(page).to have_content("Editing Example document")
        end
      end

      scenario "adding a nil attachment on a #{publication_state} CMA case" do
        # this is to force app to not update asset manager on invalid error
        stub_request(:post, "#{Plek.find('asset-manager')}/assets")
          .to_return(body: asset_manager_response.to_json, status: 500)

        click_link "Add attachment"
        expect(page.status_code).to eq(200)

        fill_in "Title", with: "Updated cma case image"

        click_button("Save attachment")

        expect(page.status_code).to eq(200)
        expect(page).to have_content("Adding an attachment failed. Please make sure you have uploaded an attachment")
      end

      scenario "editing an attachment on a #{publication_state} CMA case" do
        stub_request(:put, %r{#{Plek.find('asset-manager')}/assets/.*})
          .to_return(body: asset_manager_response.to_json, status: 201)
        find(".attachments").first(:link, "edit").click
        expect(page.status_code).to eq(200)
        expect(find("#attachment_title").value).to eq("asylum report image title")

        expect(page).to have_content("asylum-support-image.jpg")
        fill_in "Title", with: "Updated cma case image"
        page.attach_file("attachment_file", "spec/support/images/updated_cma_case_image.jpg")

        click_button("Save attachment")

        expect(page.status_code).to eq(200)
        expect(page).to have_content("Editing Example CMA Case")
      end

      scenario "deleting an attachment on a CMA case" do
        stub_request(:delete, %r{#{Plek.find('asset-manager')}/assets/.*})
          .to_return(body: asset_manager_response.to_json, status: 200)
        find(".attachments").first(:button, "delete").click
        expect(page.status_code).to eq(200)

        # TODO: fix tests so that asset manager is updated appropriately
        # expect(page).not_to have_content('asylum-support-image.jpg')

        expect(page).to have_content("Editing Example CMA Case")
      end

      scenario "previewing GovSpeak", js: true do
        fill_in "Body", with: "$CTA some text $CTA"

        click_link "Preview"

        within(".preview_container") do
          expect(page).to have_content("some text")
          expect(page).not_to have_content("$CTA")
        end

        fill_in "Body", with: "[InlineAttachment:asylum-support-image.jpg]"

        click_link "Preview"

        within(".preview_container") do
          expect(page).to have_content("asylum report image title")
          expect(page).not_to have_content("[InlineAttachment:")
        end

        fill_in "Body", with: "[link text](http://www.example.com)"

        click_link "Preview"

        within(".preview_container") do
          expect(page).to have_content("link text")
          expect(page).not_to have_content("http://www.example.com")
          expect(page).not_to have_content("some text")
        end
      end
    end
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
      click_button "Save as draft"

      expect(page).to have_content("There is a problem")
      expect(page).to have_content("Update type can't be blank")

      expect(page.status_code).to eq(422)
    end

    scenario "updating the title does not update the base path" do
      fill_in "Title", with: "New title"
      choose "Minor"
      click_button "Save as draft"
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
      click_button "Save as draft"
      expect(page).to have_content("Updated Example CMA Case")
      expect(page.status_code).to eq(200)
    end
  end
end
