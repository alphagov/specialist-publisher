require "spec_helper"

RSpec.describe ManualSectionsAttachmentsController, type: :controller do
  let(:manual) { Payloads.manual_content_item }
  let(:manual_links) { Payloads.manual_links }
  let(:sections) { Payloads.section_content_items }
  let(:sections_links) { Payloads.section_links }
  let(:section_payload) {
    sections.first.deep_merge(
      "details" => {
        "attachments" => [
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
    )
  }
  let(:section_links) { sections_links.first }
  let(:section_content_id) { section_payload['content_id'] }
  let(:attachment_content_id) { section_payload['details']['attachments'][0]['content_id'] }
  let(:asset_id) { SecureRandom.uuid }
  let(:file_name) { "section_image.jpg" }
  let(:file_url) { "http://assets-origin.dev.gov.uk/media/#{asset_id}/#{file_name}" }

  let(:asset_url) { "http://assets-origin.dev.gov.uk/media/#{asset_id}/#{file_name}" }
  let(:asset_manager_response) {
    {
      id: 'http://asset-manager.dev.gov.uk/assets/another_image_id',
      file_url: asset_url
    }
  }

  let(:section) { Section.find(content_id: section_content_id) }

  before do
    log_in_as_gds_editor
    publishing_api_has_item(manual)
    publishing_api_has_links(manual_links)
    publishing_api_has_item(section_payload)
    publishing_api_has_links(section_links)

    allow_any_instance_of(ManualSectionsAttachmentsController).to receive(:fetch_section).and_return(section)
  end

  describe "POST create" do
    let(:attachment) {
      {
        file: Rack::Test::UploadedFile.new("spec/support/images/cma_case_image.jpg", "image/jpg"),
        title: 'test attachment upload'
      }
    }

    it "redirect to the specialist document edit page" do
      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links

      stub_request(:post, "#{Plek.find('asset-manager')}/assets")
        .with(body: %r{.*})
        .to_return(body: JSON.dump(asset_manager_response), status: 201)

      post :create, manual_content_id: section.manual_content_id, section_content_id: section.content_id, attachment: attachment

      expect(section.attachments.count).to eq(3)
      expect(response).to redirect_to(edit_manual_section_path(manual_content_id: section.manual_content_id, content_id: section.content_id))
    end
  end

  describe "GET edit" do
    it "renders the edit attachment form" do
      attachment = section.attachments.find(attachment_content_id)

      get :edit, manual_content_id: section.manual_content_id, section_content_id: section.content_id, attachment_content_id: attachment_content_id

      expect(assigns(:attachment)).to eq(attachment)
      expect(response).to render_template :edit
    end
  end

  describe "PUT update" do
    it "redirects to the specalist document edit page" do
      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links
      stub_request(:post, "#{Plek.find('asset-manager')}/assets")
        .with(body: %r{.*})
        .to_return(body: JSON.dump(asset_manager_response), status: 201)

      post :update, manual_content_id: section.manual_content_id,
                    section_content_id: section.content_id,
                    attachment_content_id: attachment_content_id,
                    attachment: {
                      file: Rack::Test::UploadedFile.new("spec/support/images/updated_cma_case_image.jpg", "mime/type"),
                      title: 'updated test attachment upload'
                    }

      expect(section.attachments.count).to eq(2)
      expect(response).to redirect_to(edit_manual_section_path(manual_content_id: section.manual_content_id, content_id: section.content_id))
    end
  end
end
