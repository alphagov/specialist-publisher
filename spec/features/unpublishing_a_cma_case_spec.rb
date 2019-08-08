require 'spec_helper'

RSpec.feature "Unpublishing a CMA Case", type: :feature do
  let(:content_id) { item['content_id'] }

  before do
    log_in_as_editor(:cma_editor)
    publishing_api_has_item(item)
  end

  context "a published document" do
    let(:item) {
      FactoryBot.create(:cma_case,
                        title: "Example CMA Case",
                        publication_state: "published")
    }

    scenario "clicking the unpublish button redirects back to the show page" do
      stub_publishing_api_unpublish(content_id, body: { type: 'gone' })

      visit document_path(content_id: content_id, document_type_slug: "cma-cases")
      expect(page).to have_content("Example CMA Case")
      click_button "Unpublish document"
      expect(page.status_code).to eq(200)
      expect(page).to have_content("Unpublished Example CMA Case")

      assert_publishing_api_unpublish(content_id)
    end

    scenario "specifying a redirect to an alternative GOV.UK content path" do
      stub_publishing_api_unpublish(content_id, body: { type: 'redirect', alternative_path: "/government/organisations/competition-and-markets-authority" })

      publishing_api_has_lookups("/government/organisations/competition-and-markets-authority" => SecureRandom.uuid)

      visit document_path(content_id: content_id, document_type_slug: "cma-cases")
      expect(page).to have_content("Example CMA Case")

      fill_in "alternative_path", with: "/government/organisations/competition-and-markets-authority"
      click_button "Unpublish document"

      expect(page.status_code).to eq(200)
      expect(page).to have_content("Unpublished Example CMA Case")

      assert_publishing_api_unpublish(content_id, type: "redirect", alternative_path: "/government/organisations/competition-and-markets-authority")
    end

    scenario "specifying a redirect to an alternative GOV.UK content path that does not exist" do
      publishing_api_has_lookups("/government/organisations/competition-and-markets-authority" => SecureRandom.uuid)

      visit document_path(content_id: content_id, document_type_slug: "cma-cases")
      expect(page).to have_content("Example CMA Case")

      fill_in "alternative_path", with: "/path/to/missing"
      click_button "Unpublish document"

      expect(page.status_code).to eq(200)
      expect(page).to have_content("Alternative content not found at the path '/path/to/missing'")
    end

    scenario "writers don't see a unpublish document button" do
      log_in_as_editor(:cma_writer)

      visit document_path(content_id: content_id, document_type_slug: "cma-cases")

      expect(page).to have_no_selector(:button, 'Unpublish document')
    end

    context "with attachments" do
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
            "url" => "https://assets.digital.cabinet-office.gov.uk/media/513a0efbed915d425e000004/asylum-support-pdf.pdf",
            "content_type" => "application/pdf",
            "title" => "asylum report pdf title",
            "created_at" => "2015-12-03T16:59:13+00:00",
            "updated_at" => "2015-12-03T16:59:13+00:00"
          }
        ]
      }

      let(:item) {
        FactoryBot.create(
          :cma_case,
          :published,
          title: "Example CMA Case",
          details: { "attachments" => existing_attachments }
        )
      }

      scenario "clicking the unpublish button deletes document attachments" do
        Sidekiq::Testing.inline! do
          stub_publishing_api_unpublish(content_id, body: { type: 'gone' })

          visit document_path(content_id: content_id, document_type_slug: "cma-cases")

          expect(Services.asset_api).to receive(:delete_asset).once.ordered
            .with("513a0efbed915d425e000002")
          expect(Services.asset_api).to receive(:delete_asset).once.ordered
            .with("513a0efbed915d425e000004")

          click_button "Unpublish document"

          expect(page.status_code).to eq(200)
          expect(page).to have_content("Unpublished Example CMA Case")
        end
      end
    end
  end

  context "publishing-api returns error" do
    let(:item) {
      FactoryBot.create(:cma_case,
                        title: "Example CMA Case",
                        publication_state: "published")
    }

    scenario "clicking the unpublish button shows an error message" do
      stub_publishing_api_unpublish(content_id, { body: { type: 'gone' } }, status: 409)

      visit document_path(content_id: content_id, document_type_slug: "cma-cases")
      expect(page).to have_content("Example CMA Case")
      click_button "Unpublish document"
      expect(page.status_code).to eq(200)
      expect(page).to have_content("Something has gone wrong. Please try again and see if it works.")
    end
  end
end
