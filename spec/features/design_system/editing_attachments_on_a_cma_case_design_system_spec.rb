require "spec_helper"

RSpec.feature "Editing attachments on a CMA case", type: :feature do
  let(:cma_case) do
    FactoryBot.create(:cma_case, publication_state, title: "Example CMA Case", details: {
      "attachments" => existing_attachments,
    })
  end
  let(:content_id) { cma_case["content_id"] }
  let(:locale) { cma_case["locale"] }
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
    Timecop.freeze(Time.zone.parse("2015-12-03T16:59:13+00:00"))
    log_in_as_design_system_editor(:cma_editor)

    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links

    stub_publishing_api_has_content([cma_case], hash_including(document_type: CmaCase.document_type))
    stub_publishing_api_has_item(cma_case)

    stub_request(:post, "#{Plek.find('asset-manager')}/assets")
      .to_return(body: asset_manager_response.to_json, status: 201)

    visit "/cma-cases/#{content_id}:#{locale}"
    click_link "Edit document"
  end

  after do
    Timecop.return
  end

  %i[draft published].each do |publication_state|
    let(:publication_state) { publication_state }

    # TODO: this test isn't actually checking that the attachment has been added
    # Skipping - this test doesn't actually test the real flow, but modifies expected values to fake an attachment upload. It's failing in an odd way. We will need to rewrite the flow entirely anyways when we add interstitial pages for attachments.
    xscenario "adding an attachment to a #{publication_state} CMA case" do
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
      expect(page).to have_content("Editing CMA Case")
      expect(page).to have_content("New cma case image")
      expect(page).to have_content("[InlineAttachment:asylum-support-image.jpg]")

      fill_in "Body", with: "[InlineAttachment:asylum-support-image.jpg]"
      choose "Minor"

      stub_publishing_api_has_item(updated_cma_case)

      click_button "Save"

      update_govspeak_body_in_payload(updated_cma_case, existing_attachments)

      assert_publishing_api_put_content(content_id, write_payload(updated_cma_case))

      expect(page).to have_content("[InlineAttachment:asylum-support-image.jpg]")
    end

    scenario "editing an attachment on a #{publication_state} CMA case" do
      # this is to force app to not update asset manager on only-name edits
      stub_request(:post, "#{Plek.find('asset-manager')}/assets")
        .with(body: %r{.*})
        .to_return(body: asset_manager_response.to_json, status: 500)

      expect(page).to have_link("Delete attachment")
      find(".attachments").first(:link, "Edit attachment").click
      expect(page.status_code).to eq(200)
      expect(find("#attachment_title").value).to eq("asylum report image title")

      fill_in "Title", with: "Updated cma case image"

      click_button("Save attachment")

      expect(page.status_code).to eq(200)
      expect(page).to have_content("Editing CMA Case")
    end

    context "when the document is in an invalid state" do
      let(:cma_case) { FactoryBot.create(:cma_case, details: { body: "" }) }

      scenario "successfully adding an attachment to the invalid document" do
        click_link "Add attachment"

        fill_in "Title", with: "Some title"
        page.attach_file("attachment_file", "spec/support/images/cma_case_image.jpg")
        click_button "Save attachment"

        expect(page.status_code).to eq(200)
        expect(page).to have_content("Editing CMA Case")
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
      find(".attachments").first(:link, "Edit attachment").click
      expect(page.status_code).to eq(200)
      expect(find("#attachment_title").value).to eq("asylum report image title")

      expect(page).to have_content("asylum-support-image.jpg")
      fill_in "Title", with: "Updated cma case image"
      page.attach_file("attachment_file", "spec/support/images/updated_cma_case_image.jpg")

      click_button("Save attachment")

      expect(page.status_code).to eq(200)
      expect(page).to have_content("Editing CMA Case")
    end

    scenario "deleting an attachment on a CMA case" do
      stub_request(:delete, %r{#{Plek.find('asset-manager')}/assets/.*})
        .to_return(body: asset_manager_response.to_json, status: 200)
      find(".attachments").first(:link, "Delete attachment").click
      expect(page.status_code).to eq(200)
      click_button "Delete"
      expect(page.status_code).to eq(200)

      # TODO: fix tests so that asset manager is updated appropriately
      # expect(page).not_to have_content('asylum-support-image.jpg')

      expect(page).to have_content("Editing CMA Case")
    end

    # TODO: preview govspeak for attachments is taken care of in a different story. This functionality doesn't work in the new design system for now.
    xscenario "previewing GovSpeak", js: true do
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
