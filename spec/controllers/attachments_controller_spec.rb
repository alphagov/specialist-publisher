require "spec_helper"

RSpec.describe AttachmentsController, type: :controller do
  def cma_case_content_item
    {
      "content_id" => "4a656f42-35ad-4034-8c7a-08870db7fffe",
      "base_path" => "/cma-cases/example-cma-case",
      "title" => "Example CMA Case",
      "description" => "This is the summary of an example CMA case",
      "document_type" => "cma_case",
      "schema_name" => "specialist_document",
      "publishing_app" => "specialist-publisher",
      "rendering_app" => "specialist-frontend",
      "locale" => "en",
      "phase" => "live",
      "public_updated_at" => "2015-11-23T14:07:47.240Z",
      "publication_state" => "draft",
      "details" => {
        "body" => "## Header" + ("\r\n\r\nThis is the long body of an example CMA case" * 10),
        "attachments" => [
          {
            "content_id"=> "77f2d40e-3853-451f-9ca3-a747e8402e34",
            "url" => "https://assets.digital.cabinet-office.gov.uk/media/513a0efbed915d425e000002/asylum-support-image.jpg",
            "content_type"=> "application/jpeg",
            "title"=> "asylum report image title",
            "created_at"=> "2015-12-03T16:59:13+00:00",
            "updated_at"=> "2015-12-03T16:59:13+00:00"
          },
          {
            "content_id"=> "ec3f6901-4156-4720-b4e5-f04c0b152141",
            "url"=> "https://assets.digital.cabinet-office.gov.uk/media/513a0efbed915d425e000002/asylum-support-pdf.pdf",
            "content_type"=> "application/pdf",
            "title"=> "asylum report pdf title",
            "created_at"=> "2015-12-03T16:59:13+00:00",
            "updated_at"=> "2015-12-03T16:59:13+00:00"
          }
        ],
        "metadata" => {
          "opened_date" => "2014-01-01",
          "case_type" => "ca98-and-civil-cartels",
          "case_state" => "open",
          "market_sector" => ["energy"],
          "document_type" => "cma_case",
        },
        "change_history" => [
          {
            "public_timestamp" => "2015-11-23T14:07:47.240Z",
            "note" => "First published."
          }
        ]
      },
      "routes" => [
        {
          "path" => "/cma-cases/example-cma-case",
          "type" => "exact",
        }
      ],
      "redirects" => [],
      "update_type" => "major",
    }
  end

  let(:cma_case) { cma_case_content_item }
  let(:document_type) { cma_case['document_type']}
  let(:document_content_id) { cma_case['content_id']}
  let(:attachment_content_id) { cma_case['details']['attachments'][0]['content_id']}
  let(:file_name) { "cma_case_image.jpg" }
  let(:asset_url) { "http://assets-origin.dev.gov.uk/media/56c45553759b740609000000/#{file_name}" }

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

  describe "GET new" do
    it "renders the new attachment form" do
      get :new, document_type: document_type, document_content_id: document_content_id
      expect(response).to render_template :new
    end
  end

  describe "POST create" do
    it "renders the specialist document edit page" do
      document = CmaCase.find(document_content_id)
      allow_any_instance_of(AttachmentsController).to receive(:fetch_document).and_return(document)
      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links
      request = stub_request(:post, "#{Plek.find('asset-manager')}/assets").
        with(:body => %r{.*}).
        to_return(:body => JSON.dump(asset_manager_response), :status => 201)

      post :create, document_type: document_type, document_content_id: document_content_id, attachment: {file: Rack::Test::UploadedFile.new("spec/support/images/cma_case_image.jpg", "mime/type"), title: 'test attachment upload'}

      expect(response).to redirect_to(edit_document_path(document_type: document_type, content_id: document_content_id))
    end
  end

  describe "GET edit" do
    it "renders the edit attachment form" do
      document = CmaCase.find(document_content_id)
      allow_any_instance_of(AttachmentsController).to receive(:fetch_document).and_return(document)
      get :edit, document_type: document_type, document_content_id: document_content_id, attachment_content_id: attachment_content_id

      expect(response).to render_template :edit
    end
  end
end

