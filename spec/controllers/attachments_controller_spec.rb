require "spec_helper"

RSpec.describe AttachmentsController, type: :controller do
  let(:cma_case) {
    Payloads.cma_case_content_item("details" => {
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
    })}

  let(:document_type) { 'cma-cases' }
  let(:document_content_id) { cma_case['content_id'] }
  let(:attachment_content_id) { cma_case['details']['attachments'][0]['content_id'] }

  let(:asset_id) { SecureRandom.uuid }
  let(:file_name) { "cma_case_image.jpg" }
  let(:file_url) { "http://assets-origin.dev.gov.uk/media/#{asset_id}/#{file_name}" }

  let(:asset_url) { "http://assets-origin.dev.gov.uk/media/#{asset_id}/#{file_name}" }
  let(:asset_manager_response) {
    {
         id: 'http://asset-manager.dev.gov.uk/assets/another_image_id',
        file_url: asset_url
    }
  }

  before do
    log_in_as_gds_editor
    publishing_api_has_item(cma_case)
  end

  describe "POST create" do
    let(:attachment) {
      {
        file: Rack::Test::UploadedFile.new("spec/support/images/cma_case_image.jpg", "image/jpg"),
        title: 'test attachment upload'
      }
    }

    it "redirect to the specialist document edit page" do
      document = CmaCase.find(document_content_id)
      allow_any_instance_of(AttachmentsController).to receive(:fetch_document).and_return(document)

      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links

      stub_request(:post, "#{Plek.find('asset-manager')}/assets")
        .with(body: %r{.*})
        .to_return(body: JSON.dump(asset_manager_response), status: 201)

      post :create, document_type: document_type, document_content_id: document_content_id, attachment: attachment

      expect(document.attachments.count).to eq(3)
      expect(response).to redirect_to(edit_document_path(document_type: document_type, content_id: document_content_id))
    end
  end

  describe "GET edit" do
    it "renders the edit attachment form" do
      document = CmaCase.find(document_content_id)
      attachment = document.find_attachment(attachment_content_id)
      allow_any_instance_of(AttachmentsController).to receive(:fetch_document).and_return(document)

      get :edit, document_type: document_type, document_content_id: document_content_id, attachment_content_id: attachment_content_id

      expect(assigns(:attachment)).to eq(attachment)
      expect(response).to render_template :edit
    end
  end

  describe "PUT update" do
    it "redirects to the specalist document edit page" do
      document = CmaCase.find(document_content_id)
      allow_any_instance_of(AttachmentsController).to receive(:fetch_document).and_return(document)

      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links
      stub_request(:post, "#{Plek.find('asset-manager')}/assets")
        .with(body: %r{.*})
        .to_return(body: JSON.dump(asset_manager_response), status: 201)

      post :update, document_type: document_type, document_content_id: document_content_id, attachment_content_id: attachment_content_id, attachment: { file: Rack::Test::UploadedFile.new("spec/support/images/updated_cma_case_image.jpg", "mime/type"), title: 'updated test attachment upload' }

      expect(document.attachments.count).to eq(2)
      expect(response).to redirect_to(edit_document_path(document_type: document_type, content_id: document_content_id))
    end
  end
end
