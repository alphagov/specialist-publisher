require "spec_helper"

RSpec.feature "Publishing a CMA case", type: :feature do
  let(:content_id) { item["content_id"] }
  let(:publish_disable_with_message) { page.find_button("Publish")["data-disable-with"] }

  before do
    Timecop.freeze(Time.zone.parse("2015-12-03T16:59:13+00:00"))
    log_in_as_editor(:cma_editor)

    stub_publishing_api_has_content([item], hash_including(document_type: CmaCase.document_type))
    stub_publishing_api_has_item(item)

    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links
    stub_publishing_api_publish(content_id, {})
    stub_email_alert_api_accepts_content_change
  end

  after do
    Timecop.return
  end

  context "when the document is a new draft" do
    let(:item) do
      FactoryBot.create(
        :cma_case,
        title: "Example CMA Case",
        base_path: "/cma-cases/example-cma-case",
        public_updated_at: "2015-11-16T11:53:30+00:00",
        publication_state: "draft",
      )
    end

    let(:published_item) do
      FactoryBot.create(
        :cma_case,
        :published,
        content_id:,
        title: "Example CMA Case",
        base_path: "/cma-cases/example-cma-case",
        public_updated_at: "2015-11-16T11:53:30+00:00",
      )
    end

    scenario "from the index" do
      visit "/cma-cases"
      expect(page.status_code).to eq(200)

      click_link "Example CMA Case"
      expect(page.status_code).to eq(200)
      expect(page).to have_content("Example CMA Case")

      stub_publishing_api_has_item_in_sequence(content_id, [item, published_item])

      expect(AttachmentRestoreWorker).not_to receive(:perform_async)

      click_link "Publish document"
      expect(page.status_code).to eq(200)
      click_button "Publish"
      expect(page).to have_content("Published Example CMA Case")

      changed_json = { "change_note" => "First published." }

      assert_publishing_api_put_content(content_id, request_json_includes(changed_json))

      assert_publishing_api_publish(content_id)
      assert_email_alert_api_content_change_created
    end
  end

  context "when there is a redrafted document with a major update" do
    let(:item) do
      FactoryBot.create(
        :cma_case,
        :redrafted,
        title: "Major Update Case",
      )
    end

    scenario "adds a change note" do
      visit "/cma-cases"

      expect(page.status_code).to eq(200)

      click_link "Major Update Case"
      expect(page.status_code).to eq(200)

      click_link "Edit document"

      fill_in "Title", with: "Changed title"
      choose "Major"
      fill_in "Change note (required)", with: "Updated change note"

      click_button "Save"

      assert_publishing_api_put_content(
        content_id,
        lambda { |request|
          payload = JSON.parse(request.body)

          expect(payload["title"]).to eq("Changed title")
          expect(payload["update_type"]).to eq("major")
          expect(payload["change_note"]).to eq("Updated change note")
        },
      )
    end
  end

  context "when there is a redrafted document with a minor update" do
    let(:item) do
      FactoryBot.create(
        :cma_case,
        :redrafted,
        title: "Minor Update Case",
        update_type: "minor",
      )
    end

    scenario "alerts should not be sent when the item is published" do
      visit "/cma-cases"

      expect(page.status_code).to eq(200)

      click_link "Minor Update Case"

      expect(page.status_code).to eq(200)
      expect(page).to have_content("Minor Update Case")

      click_link "Publish document"
      expect(page.status_code).to eq(200)
      click_button "Publish"
      expect(page.status_code).to eq(200)
      expect(page).to have_content("Published Minor Update Case")

      assert_publishing_api_publish(content_id)

      assert_not_requested(:post, "#{Plek.find('email-alert-api')}/notifications")
    end
  end

  context "when the document is unpublished with new draft" do
    let(:content_id) { item["content_id"] }

    let(:existing_attachments) { [] }

    let(:item) do
      FactoryBot.create(
        :cma_case,
        :unpublished,
        title: "Example CMA Case",
        publication_state: "draft",
        state_history: { "1" => "unpublished", "2" => "draft" },
        details: { attachments: existing_attachments },
      )
    end

    before do
      log_in_as_editor(:cma_editor)

      stub_publishing_api_has_content([item], hash_including(document_type: CmaCase.document_type))
      stub_publishing_api_has_item(item)

      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links
      stub_publishing_api_publish(content_id, {})
      stub_email_alert_api_accepts_content_change

      visit "/cma-cases/#{content_id}"
    end

    context "a new draft of a previously unpublished document with attachments" do
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

      describe "#publish" do
        it "restores the assets via the asset api" do
          expect(Services.asset_api).to receive(:restore_asset).once.ordered
                                                               .with("513a0efbed915d425e000002")
          expect(Services.asset_api).to receive(:restore_asset).once.ordered
                                                               .with("513a0efbed915d425e000004")

          Sidekiq::Testing.inline! do
            click_on "Publish document"
            click_on "Publish"
          end
        end
      end
    end

    context "a new draft of a previously unpublished document without attachments" do
      describe "#publish" do
        it "doesn't call the asset api" do
          expect(Services.asset_api).not_to receive(:restore_asset)

          Sidekiq::Testing.inline! do
            click_on "Publish document"
            click_on "Publish"
          end
        end
      end
    end
  end
end
