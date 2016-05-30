require 'spec_helper'

RSpec.feature "Editing a draft CMA case", type: :feature do
  let(:cma_case) {
    FactoryGirl.create(:cma_case,
      title: "Example CMA Case",
      publication_state: "draft")
  }

  let(:content_id) { cma_case['content_id'] }

  before do
    log_in_as_editor(:cma_editor)

    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links

    publishing_api_has_content([cma_case], hash_including(document_type: CmaCase.document_type))
    publishing_api_has_item(cma_case)

    Timecop.freeze(Time.parse("2015-12-03T16:59:13+00:00"))

    visit "/cma-cases/#{content_id}"
    click_link "Edit document"
  end

  after do
    Timecop.return
  end

  scenario "with some changed attributes" do
    updated_cma_case = cma_case.deep_merge(
      "title" => "Changed title",
      "description" => "Changed summary",
      "public_updated_at" => "2015-12-03T16:59:13+00:00",
      "details" => {
        "metadata" => {
          "opened_date" => "2014-01-01",
          "market_sector" => ["energy"],
        },
        "body" => [
          {
            "content_type" => "text/govspeak",
            "content" => "## Header" + ("\r\n\r\nThis is the long body of an example CMA case" * 2)
          },
          {
            "content_type" => "text/html",
            "content" => ("<h2 id=\"header\">Header</h2>\n" + "\n<p>This is the long body of an example CMA case</p>\n" * 2)
          }
        ],
        "headers" => [{
          "text" => "Header",
          "level" => 2,
          "id" => "header",
        }],
      }
    )
    expected_sent_payload = saved_for_the_first_time(write_payload(updated_cma_case))

    fill_in "Title", with: "Changed title"
    fill_in "Summary", with: "Changed summary"
    fill_in "Body", with: "## Header" + ("\n\nThis is the long body of an example CMA case" * 2)
    fill_in "Opened date", with: "2014-01-01"
    select "Energy", from: "Market sector"

    expect(page).to have_css('div.govspeak-help')
    expect(page).to have_content('Add attachment')

    click_button "Save as draft"

    assert_publishing_api_put_content(content_id, expected_sent_payload)

    expect(page.status_code).to eq(200)
    expect(page).to have_content("Updated Changed title")
  end

  scenario "with some invalid changed attributes" do
    fill_in "Title", with: "Changed title"
    fill_in "Summary", with: "Changed summary"
    fill_in "Body", with: "<script>alert('hello')</script>"
    fill_in "Opened date", with: "Not a date"
    select "Energy", from: "Market sector"

    click_button "Save as draft"

    expect(page).to have_css('.elements-error-summary')
    expect(page).to have_css('.elements-error-message')

    expect(page).to have_content("Opened date should be formatted YYYY-MM-DD")
    expect(page).to have_content("Body cannot include invalid Govspeak")
    expect(page).to have_content("Please fix the following errors")

    expect(page.status_code).to eq(422)
  end

  context "with attachments" do
    let(:asset_manager_response) {
      {
        id: 'http://asset-manager.dev.gov.uk/assets/another_image_id',
        file_url: "http://assets-origin.dev.gov.uk/media/56c45553759b740609000000/cma_case_image.jpg",
      }
    }
    let(:existing_attachments) {
      [
        {
          "content_id" => "77f2d40e-3853-451f-9ca3-a747e8402e34",
          "url" => "https://assets.digital.cabinet-office.gov.uk/media/513a0efbed915d425e000002/asylum-support-image.jpg",
          "content_type" => "application/jpeg",
          "title" => "asylum report image title",
          "created_at" => "2015-12-03T16:59:13+00:00",
          "updated_at" => "2015-12-03T16:59:13+00:00"
        },
        {
          "content_id" => "ec3f6901-4156-4720-b4e5-f04c0b152141",
          "url" => "https://assets.digital.cabinet-office.gov.uk/media/513a0efbed915d425e000002/asylum-support-pdf.pdf",
          "content_type" => "application/pdf",
          "title" => "asylum report pdf title",
          "created_at" => "2015-12-03T16:59:13+00:00",
          "updated_at" => "2015-12-03T16:59:13+00:00"
        }
      ]
    }

    let(:cma_case) {
      FactoryGirl.create(:cma_case,
        title: "Example CMA Case",
        publication_state: "draft",
        details: { "attachments" => existing_attachments })
    }

    before do
      stub_request(:post, "#{Plek.find('asset-manager')}/assets")
        .with(body: %r{.*})
        .to_return(body: asset_manager_response.to_json, status: 201)
    end

    scenario "adding an attachment" do
      click_link "Add attachment"
      expect(page.status_code).to eq(200)

      fill_in "Title", with: "New cma case image"
      page.attach_file('attachment_file', "spec/support/images/cma_case_image.jpg")

      click_button "Save attachment"
      expect(page.status_code).to eq(200)

      expect(page).to have_content("Editing Example CMA Case")
    end

    scenario "editing an attachment" do
      find('.attachments').first(:link, "edit").click

      expect(page.status_code).to eq(200)

      fill_in "Title", with: "Updated cma case image"
      page.attach_file('attachment_file', "spec/support/images/updated_cma_case_image.jpg")

      click_button("Save attachment")

      expect(page.status_code).to eq(200)
      expect(page).to have_content("Editing Example CMA Case")
    end
  end
end
