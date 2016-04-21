require 'spec_helper'

RSpec.feature "Creating a Manual", type: :feature do
  context 'as a GDS editor' do
    def test_content_id
      "b1dc075f-d946-4bcb-a5eb-941f8c8188cf"
    end

    def test_base_path
      "/guidance/my-new-manual"
    end

    def stub_json
      {
        base_path: test_base_path,
        content_id: test_content_id,
        title: "My New Manual",
        description: "Summary of new manual",
        details: {
          body: "The body of my new manual. The body of my new manual. The body of my new manual."
        }
      }
    end

    def manual_links
      {
        "content_id" => test_content_id,
        "links" => {
          "sections" => [
          ],
          "organisations" => ["af07d5a5-df63-4ddc-9383-6a666845ebe9"]
        }
      }
    end

    let(:fields) { %i[content_id description title details public_updated_at publication_state base_path update_type] }

    before do
      log_in_as_editor(:gds_editor)
      #make manual content items... before they just needed ids now needs other fields1
      publishing_api_has_content([], document_type: "manual", fields: fields, per_page: 10000)

      stub_publishing_api_put_content(test_content_id, {})
      stub_publishing_api_patch_links(test_content_id, {})
      publishing_api_has_item(stub_json)
      publishing_api_has_links(manual_links)

      organisation = {
        content_id: manual_links['links']['organisations'][0],
        base_path: "/government/organisations/"
      }
      publishing_api_has_item(organisation)

      allow(SecureRandom).to receive(:uuid).and_return(stub_json[:content_id])
    end

    scenario 'from the index page to /manuals/new' do
      visit '/manuals'

      expect(page).to have_content("New manual")

      click_link "New manual"

      expect(page.status_code).to eq(200)
      expect(page.current_path).to eq("/manuals/new")
    end

    scenario 'creating a new valid manual' do
      visit '/manuals/new'

      expect(page).to have_field('Title')
      fill_in "Title", with: "My New Manual"

      expect(page).to have_field('Summary')
      fill_in "Summary", with: "Summary of new manual"

      expect(page).to have_field('Body')
      fill_in "Body", with: "The body of my new manual. The body of my new manual. The body of my new manual."

      click_button "Save as draft"

      assert_publishing_api_put_content(
        test_content_id,
        request_json_includes("base_path" => test_base_path)
      )

      assert_publishing_api_put_content(
        test_content_id,
        request_json_includes(
          "routes" => [
            { "path" => test_base_path, "type" => "exact" }
          ]
        )
      )

      assert_publishing_api_put_content(
        test_content_id,
        request_json_includes(
          "details" => {
            "body" => "The body of my new manual. The body of my new manual. The body of my new manual.",
            "child_section_groups" => [],
            "change_notes" => [],
          }
        )
      )

      assert_publishing_api_patch_links(
        test_content_id,
        request_json_includes(
          "links" => {
            "organisations" => ["af07d5a5-df63-4ddc-9383-6a666845ebe9"]
          }
        )
      )

      expect(page.status_code).to eq(200)
      expect(page).to have_content("Summary of new manual")
    end
  end
end
