require "spec_helper"

RSpec.feature "Unpublishing a document", type: :feature do
  let(:content_id) { item["content_id"] }
  let(:locale) { item["locale"] }

  before do
    log_in_as_editor(:cma_editor)
    stub_publishing_api_has_item(item)
  end

  context "a published document" do
    let(:item) do
      FactoryBot.create(
        :cma_case,
        title: "Example CMA Case",
        publication_state: "published",
      )
    end

    scenario "clicking the unpublish button redirects back to the show page" do
      stub_publishing_api_unpublish(content_id, body: { type: "gone", locale: })

      visit document_path(content_id_and_locale: "#{content_id}:#{locale}", document_type_slug: "cma-cases")
      expect(page).to have_content("Example CMA Case")
      click_link "Unpublish document"
      expect(page.status_code).to eq(200)
      click_button "Unpublish"
      expect(page.status_code).to eq(200)
      expect(page).to have_content("Unpublished Example CMA Case")

      assert_publishing_api_unpublish(content_id)
    end

    scenario "specifying a redirect to an alternative GOV.UK content path" do
      stub_publishing_api_unpublish(content_id, body: { type: "redirect", alternative_path: "/government/organisations/competition-and-markets-authority", locale: })

      stub_publishing_api_has_lookups("/government/organisations/competition-and-markets-authority" => SecureRandom.uuid)

      visit document_path(content_id_and_locale: "#{content_id}:#{locale}", document_type_slug: "cma-cases")
      expect(page).to have_content("Example CMA Case")

      click_link "Unpublish document"
      expect(page.status_code).to eq(200)
      fill_in "alternative_path", with: "/government/organisations/competition-and-markets-authority"
      click_button "Unpublish"

      expect(page.status_code).to eq(200)
      expect(page).to have_content("Unpublished Example CMA Case")

      assert_publishing_api_unpublish(content_id, type: "redirect", alternative_path: "/government/organisations/competition-and-markets-authority", locale:)
    end

    context "with attachments" do
      let(:existing_attachments) do
        [
          {
            "content_id" => "77f2d40e-3853-451f-9ca3-a747e8402e34",
            "url" => "https://assets.digital.cabinet-office.gov.uk/media/513a0efbed915d425e000002/asylum-support-image.jpg",
            "content_type" => "application/jpeg",
            "title" => "asylum report image title",
            "created_at" => "2015-12-03T16:59:13+00:00",
            "updated_at" => "2015-12-03T16:59:13+00:00",
          },
          {
            "content_id" => "ec3f6901-4156-4720-b4e5-f04c0b152141",
            "url" => "https://assets.digital.cabinet-office.gov.uk/media/513a0efbed915d425e000004/asylum-support-pdf.pdf",
            "content_type" => "application/pdf",
            "title" => "asylum report pdf title",
            "created_at" => "2015-12-03T16:59:13+00:00",
            "updated_at" => "2015-12-03T16:59:13+00:00",
          },
        ]
      end

      let(:item) do
        FactoryBot.create(
          :cma_case,
          :published,
          title: "Example CMA Case",
          details: { "attachments" => existing_attachments },
        )
      end

      scenario "clicking the unpublish button deletes document attachments" do
        Sidekiq::Testing.inline! do
          stub_publishing_api_unpublish(content_id, body: { type: "gone", locale: })

          visit document_path(content_id_and_locale: "#{content_id}:#{locale}", document_type_slug: "cma-cases")

          expect(Services.asset_api).to receive(:delete_asset).once.ordered
            .with("513a0efbed915d425e000002")
          expect(Services.asset_api).to receive(:delete_asset).once.ordered
            .with("513a0efbed915d425e000004")

          click_link "Unpublish document"
          expect(page.status_code).to eq(200)
          click_button "Unpublish"

          expect(page.status_code).to eq(200)
          expect(page).to have_content("Unpublished Example CMA Case")
        end
      end
    end
  end

  context "publishing-api returns error" do
    let(:item) do
      FactoryBot.create(
        :cma_case,
        title: "Example CMA Case",
        publication_state: "published",
      )
    end

    scenario "clicking the unpublish button shows an error message" do
      stub_publishing_api_unpublish(content_id, { body: { type: "gone", locale: } }, status: 409)

      visit document_path(content_id_and_locale: "#{content_id}:#{locale}", document_type_slug: "cma-cases")
      expect(page).to have_content("Example CMA Case")
      click_link "Unpublish document"
      expect(page.status_code).to eq(200)
      click_button "Unpublish"
      expect(page.status_code).to eq(200)
      expect(page).to have_content("Something has gone wrong. Please try again and see if it works.")
    end

    scenario "clicking the unpublish button shows an error message if invalid URL specified" do
      alternative_path = "https://www.invalid.com"

      stub_publishing_api_unpublish(content_id, { body: { type: "redirect", locale:, alternative_path: } }, status: 409)

      visit document_path(content_id_and_locale: "#{content_id}:#{locale}", document_type_slug: "cma-cases")
      expect(page).to have_content("Example CMA Case")
      click_link "Unpublish document"
      expect(page.status_code).to eq(200)
      fill_in "alternative_path", with: alternative_path
      click_button "Unpublish"
      expect(page.status_code).to eq(200)
      expect(page).to have_content("Failed to unpublish. The provided URL \"https://www.invalid.com\" is not in a valid format. Please try again with a URL in the correct format.")
    end
  end
end
