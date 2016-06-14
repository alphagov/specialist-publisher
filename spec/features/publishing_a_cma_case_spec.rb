require 'spec_helper'

RSpec.feature "Publishing a CMA case", type: :feature do
  let(:content_id) { item['content_id'] }
  let(:publish_alert_message) { page.find_button('Publish')["data-message"] }
  let(:publish_disable_with_message) { page.find_button('Publish')["data-disable-with"] }

  before do
    log_in_as_editor(:cma_editor)

    publishing_api_has_content([item], hash_including(document_type: CmaCase.document_type))
    publishing_api_has_item(item)

    stub_publishing_api_publish(content_id, {})
    stub_any_rummager_post_with_queueing_enabled
    email_alert_api_accepts_alert
  end

  context "when the document is a new draft" do
    let(:item) {
      FactoryGirl.create(:cma_case,
        title: "Example CMA Case",
        base_path: "/cma-cases/example-cma-case",
        public_updated_at: "2015-11-16T11:53:30+00:00",
        publication_state: "draft")
    }

    scenario "from the index" do
      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links

      visit "/cma-cases"
      expect(page.status_code).to eq(200)

      click_link "Example CMA Case"
      expect(page.status_code).to eq(200)
      expect(page).to have_content("Example CMA Case")

      click_button "Publish"
      expect(page.status_code).to eq(200)
      expect(page).to have_content("Published Example CMA Case")


      expected_change_history = [
          {
              "public_timestamp" => STUB_TIME_STAMP,
              "note" => "First published.",
          }
      ]

      changed_json = {
          "details" => item["details"].merge("change_history" => expected_change_history)
      }

      assert_publishing_api_put_content(content_id, request_json_includes(changed_json))

      assert_publishing_api_publish(content_id)
      assert_rummager_posted_item("link" => "/cma-cases/example-cma-case")
      assert_email_alert_sent
    end

    scenario "publish warning and popup text will indicate that an email will be sent" do
      visit "/cma-cases"

      expect(page.status_code).to eq(200)

      click_link "Example CMA Case"

      expect(page.status_code).to eq(200)
      expect(page).to have_content("Example CMA Case")
      expect(page).to have_content("Publishing will email subscribers to CMA Cases.")

      expect(publish_alert_message).to eq("Publishing will email subscribers to CMA Cases. Continue?")
      expect(publish_disable_with_message).to eq("Publishing...")
    end

    scenario "writers don't see a publish button" do
      log_in_as_editor(:cma_writer)

      visit "/cma-cases"
      click_link "Example CMA Case"

      expect(page).to have_no_selector(:button, 'Publish')
      expect(page).to have_content("You don’t have permission to publish this document.")
    end
  end

  context "when the document is already published" do
    let(:item) {
      FactoryGirl.create(:cma_case,
        title: "Live Item",
        publication_state: "live")
    }

    scenario "publish buttons aren't shown" do
      visit "/cma-cases"
      expect(page.status_code).to eq(200)

      click_link "Live Item"

      expect(page).to have_no_selector(:button, 'Publish')
      expect(page).to have_content("There are no changes to publish.")
    end
  end

  context "when there is a redrafted document with a major update" do
    let(:item) {
      FactoryGirl.create(:cma_case,
        title: "Major Update Case",
        update_type: "major",
        publication_state: "redrafted")
    }

    scenario "publish warning and popup text will indicate that it is a major edit" do
      visit "/cma-cases"

      expect(page.status_code).to eq(200)

      click_link "Major Update Case"

      expect(page.status_code).to eq(200)
      expect(page).to have_content("Major Update Case")
      expect(page).to have_content("You are about to publish a major edit with a public change note.")
      expect(page).to have_content("Publishing will email subscribers to CMA Cases.")

      expect(publish_alert_message).to eq("Publishing will email subscribers to CMA Cases. Continue?")
    end
  end

  context "when there is a redrafted document with a minor update" do
    let(:item) {
      FactoryGirl.create(:cma_case,
        title: "Minor Update Case",
        update_type: "minor",
        publication_state: "redrafted")
    }

    scenario "alerts should not be sent when the item is published" do
      visit "/cma-cases"

      expect(page.status_code).to eq(200)

      click_link "Minor Update Case"

      expect(page.status_code).to eq(200)
      expect(page).to have_content("Minor Update Case")

      click_button "Publish"
      expect(page.status_code).to eq(200)
      expect(page).to have_content("Published Minor Update Case")

      assert_publishing_api_publish(content_id)

      assert_not_requested(:post, Plek.current.find('email-alert-api') + "/notifications")
    end

    scenario "publish warning and popup text will indicate that it is a minor edit" do
      visit "/cma-cases"

      expect(page.status_code).to eq(200)

      click_link "Minor Update Case"

      expect(page.status_code).to eq(200)
      expect(page).to have_content("Minor Update Case")
      expect(page).to have_content("You are about to publish a minor edit.")
      expect(page).to have_no_content("Publishing will email subscribers to CMA Cases.")

      expect(publish_alert_message).to eq("You are about to publish a minor edit. Continue?")
    end
  end

  context "when the document is unpublished" do
    let(:item) {
      FactoryGirl.create(:cma_case,
        title: "Unpublished Item",
        publication_state: "Unpublished")
    }

    scenario "when content item is unpublished, there will be a publish button" do
      visit "/cma-cases"
      expect(page.status_code).to eq(200)

      click_link "Unpublished Item"

      expect(page).to have_selector(:button, 'Publish')
      expect(page).to have_no_content("There are no changes to publish.")
    end

    scenario "publish warning and popup text will indicate that an email will be sent" do
      visit "/cma-cases"

      expect(page.status_code).to eq(200)

      click_link "Unpublished Item"

      expect(page.status_code).to eq(200)
      expect(page).to have_content("Unpublished Item")
      expect(page).to have_content("Publishing will email subscribers to CMA Cases.")

      expect(page).to have_no_content("You are about to publish a minor edit")
      expect(page).to have_no_content("You are about to publish a major edit")

      expect(publish_alert_message).to eq("Publishing will email subscribers to CMA Cases. Continue?")
    end
  end
end
