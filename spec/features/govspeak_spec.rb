require "spec_helper"

RSpec.feature "GovSpeak", type: :feature do
  before do
    log_in_as_editor(:cma_editor)
  end

  scenario "creating a document that references attachments that don't exist" do
    visit "/cma-cases/new"
    fill_in "Body", with: "[InlineAttachment:missing.pdf]"
    click_button "Save"

    expect(page).to have_content("There is a problem")
    expect(page).to have_content(
      "Body contains an attachment that can't be found: 'missing.pdf'",
    )
  end

  scenario "escaping inline attachments so that they are html safe" do
    visit "/cma-cases/new"
    fill_in "Body", with: "[InlineAttachment:<not>safe.pdf]"
    click_button "Save"

    expect(page).to have_content("There is a problem")

    expect(page).to have_content(
      "Body contains an attachment that can't be found: '<not>safe.pdf'",
    )
    expect(page).not_to have_content(
      "Body contains an attachment that can't be found: '&lt;not&gt;safe.pdf'",
    )
  end

  context "existing attachments" do
    let(:cma_case) do
      FactoryBot.create(:cma_case, :draft, title: "Example CMA Case", details: {
        "attachments" => existing_attachments,
      })
    end
    let(:content_id) { cma_case["content_id"] }
    let(:locale) { cma_case["locale"] }
    let(:existing_attachments) do
      [
        {
          "attachment_type" => "file",
          "id" => "77f2d40e-3853-451f-9ca3-a747e8402e34",
          "content_id" => "77f2d40e-3853-451f-9ca3-a747e8402e34",
          "url" => "https://assets.digital.cabinet-office.gov.uk/media/513a0efbed915d425e000001/asylum-support-image.jpg",
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
      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links
      stub_publishing_api_has_content([cma_case], hash_including(document_type: CmaCase.document_type))
      stub_publishing_api_has_item(cma_case)
    end

    scenario "previewing GovSpeak", js: true, skip: "Test is stuck on Javascript loading message. Possibly Preview controller failing to return and ajax call is stuck. Unsure how to move forward from this. Scenario is tested manually and javascript is tested in Jasmine spec" do
      visit "/cma-cases/#{content_id}:#{locale}"
      click_link "Edit document"

      fill_in "Body", with: "$CTA some text $CTA"

      click_button "Preview"
      within(".app-c-govspeak-editor__preview") do
        expect(page).to have_content("some text")
        expect(page).not_to have_content("$CTA")
      end

      click_button "Back to edit"
      fill_in "Body", with: "[InlineAttachment:asylum-support-image.jpg]"

      click_button "Preview"
      within(".app-c-govspeak-editor__preview") do
        expect(page).to have_content("asylum report image title")
        expect(page).not_to have_content("[InlineAttachment:")
      end
    end
  end
end
