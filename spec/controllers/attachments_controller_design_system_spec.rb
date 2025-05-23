require "spec_helper"

RSpec.describe AttachmentsController, type: :controller do
  let(:cma_case) do
    FactoryBot.create(
      :cma_case,
      details: {
        "attachments" => [
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
            "url" => "https://assets.digital.cabinet-office.gov.uk/media/513a0efbed915d425e000002/asylum-support-pdf.pdf",
            "content_type" => "application/pdf",
            "title" => "asylum report pdf title",
            "created_at" => "2015-12-03T16:59:13+00:00",
            "updated_at" => "2015-12-03T16:59:13+00:00",
          },
        ],
      },
    )
  end

  let(:document_type_slug) { "cma-cases" }
  let(:document_content_id) { cma_case["content_id"] }
  let(:document_locale) { "en" }
  let(:attachment_content_id) { cma_case["details"]["attachments"][0]["content_id"] }

  let(:asset_id) { SecureRandom.uuid }
  let(:file_name) { "cma_case_image.jpg" }
  let(:file_url) { "http://assets-origin.dev.gov.uk/media/#{asset_id}/#{file_name}" }

  let(:asset_url) { "http://assets-origin.dev.gov.uk/media/#{asset_id}/#{file_name}" }
  let(:asset_manager_response) do
    {
      id: "http://asset-manager.dev.gov.uk/assets/another_image_id",
      file_url: asset_url,
    }
  end

  before do
    log_in_as_design_system_gds_editor
    stub_publishing_api_has_item(cma_case)
  end

  describe "POST create" do
    let(:file) { Rack::Test::UploadedFile.new("spec/support/images/cma_case_image.jpg", "image/jpg") }
    let(:attachment) do
      {
        file:,
        title: "test attachment upload",
      }
    end

    let(:no_file_attachment) do
      {
        file: nil,
        title: "no file attached",
      }
    end

    it "redirect to the specialist document edit page" do
      document = CmaCase.find(document_content_id, document_locale)
      allow(subject).to receive(:fetch_document).and_return(document)

      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links

      stub_request(:post, "#{Plek.find('asset-manager')}/assets")
        .to_return(body: JSON.dump(asset_manager_response), status: 201)

      post :create, params: {
        document_type_slug:,
        document_content_id_and_locale: "#{document_content_id}:#{document_locale}",
        attachment:,
      }

      expect(document.attachments.count).to eq(3)
      expect(response).to redirect_to(edit_document_path(
                                        document_type_slug:,
                                        content_id_and_locale: "#{document_content_id}:#{document_locale}",
                                      ))
    end

    it "shows an error if no attachment is uploaded" do
      document = CmaCase.find(document_content_id, document_locale)
      allow(subject).to receive(:fetch_document).and_return(document)

      post :create, params: {
        document_type_slug:,
        document_content_id_and_locale: "#{document_content_id}:#{document_locale}",
        attachment: no_file_attachment,
      }

      expect(flash[:danger]).to be_present
      expect(response).to redirect_to(new_document_attachment_path(document_type_slug:))
    end
  end

  describe "GET edit" do
    it "renders the edit attachment form" do
      document = CmaCase.find(document_content_id, document_locale)
      attachment = document.attachments.find(attachment_content_id)
      allow(subject).to receive(:fetch_document).and_return(document)

      get :edit, params: {
        document_type_slug:,
        document_content_id_and_locale: "#{document_content_id}:#{document_locale}",
        attachment_content_id:,
      }

      expect(assigns(:attachment)).to eq(attachment)
      expect(response).to render_template :edit
    end
  end

  describe "PUT update" do
    before do
      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links
      stub_request(:put, %r{#{Plek.find('asset-manager')}/assets/.*})
        .to_return(body: JSON.dump(asset_manager_response), status: 201)
    end

    context "an attachment file is updated" do
      let(:document) { CmaCase.find(document_content_id, document_locale) }
      let(:updated_file) { Rack::Test::UploadedFile.new("spec/support/images/updated_cma_case_image.jpg", "mime/type") }
      let(:updated_attachment) do
        {
          file: updated_file,
          title: "updated test attachment upload",
        }
      end

      it "redirects to the specalist document edit page" do
        allow(subject).to receive(:fetch_document).and_return(document)

        patch :update, params: {
          document_type_slug:,
          document_content_id_and_locale: "#{document_content_id}:#{document_locale}",
          attachment_content_id:,
          attachment: updated_attachment,
        }

        expect(document.attachments.count).to eq(2)
        expect(response).to redirect_to(edit_document_path(
                                          document_type_slug:,
                                          content_id_and_locale: "#{document_content_id}:#{document_locale}",
                                        ))
      end

      context "update_attachment fails" do
        it "shows an error message and redirects to edit document attachment page" do
          allow(subject).to receive(:fetch_document).and_return(document)
          allow(document).to receive(:update_attachment).and_return(false)
          error_message = "There was an error updating the attachment, please try again later."

          patch :update, params: {
            document_type_slug:,
            document_content_id_and_locale: "#{document_content_id}:#{document_locale}",
            attachment_content_id:,
            attachment: updated_attachment,
          }

          expect(flash[:danger]).to eq(error_message)
          expect(response).to redirect_to(
            edit_document_attachment_path(
              document_type_slug:,
              document_content_id_and_locale: "#{document_content_id}:#{document_locale}",
              attachment_content_id:,
            ),
          )
        end
      end
    end

    context "only the attachment title is updated" do
      let(:document) { CmaCase.find(document_content_id, document_locale) }
      let(:updated_file) { Rack::Test::UploadedFile.new("spec/support/images/updated_cma_case_image.jpg", "mime/type") }
      let(:updated_attachment) do
        {
          title: "updated test attachment upload",
        }
      end

      it "updates the attachment title" do
        allow(subject).to receive(:fetch_document).and_return(document)
        success_message = "Attachment successfully updated"

        patch :update, params: {
          document_type_slug:,
          document_content_id_and_locale: "#{document_content_id}:#{document_locale}",
          attachment_content_id:,
          attachment: updated_attachment,
        }

        expect(flash[:success]).to eq(success_message)
        expect(response).to redirect_to(edit_document_path(
                                          document_type_slug:,
                                          content_id_and_locale: "#{document_content_id}:#{document_locale}",
                                        ))
      end

      context "error updating the attachment" do
        it "shows an error message and redirects to edit attachment page" do
          allow(document).to receive(:save).and_return(false)
          allow(subject).to receive(:fetch_document).and_return(document)
          error_message = "There was an error updating the title, please try again later."

          patch :update, params: {
            document_type_slug:,
            document_content_id_and_locale: "#{document_content_id}:#{document_locale}",
            attachment_content_id:,
            attachment: updated_attachment,
          }

          expect(flash[:danger]).to eq(error_message)
          expect(response).to redirect_to(edit_document_attachment_path(
                                            document_type_slug:,
                                            document_content_id_and_locale: "#{document_content_id}:#{document_locale}",
                                            attachment_content_id:,
                                          ))
        end
      end
    end

    context "the attachment fails to attach" do
      let(:no_file_attachment) do
        {
          file: nil,
          title: "No file attachment upload",
        }
      end

      it "shows an error message and redirects to the new attachment page" do
        document = CmaCase.find(document_content_id, document_locale)
        allow(subject).to receive(:fetch_document).and_return(document)
        allow(subject).to receive(:white_listed?).and_return(false)
        error_message = "Adding an attachment failed. Please make sure you have uploaded an attachment of a permitted file type."

        patch :update, params: {
          document_type_slug:,
          document_content_id_and_locale: "#{document_content_id}:#{document_locale}",
          attachment_content_id:,
          attachment: no_file_attachment,
        }

        expect(flash[:danger]).to eq(error_message)
        expect(response).to redirect_to(new_document_attachment_path(document_type_slug:))
      end
    end
  end

  describe "DELETE destroy" do
    it "redirects to the specialist document edit page" do
      document = CmaCase.find(document_content_id, document_locale)
      allow(subject).to receive(:fetch_document).and_return(document)
      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links
      stub_request(:delete, %r{#{Plek.find('asset-manager')}/assets/.*})
        .to_return(body: JSON.dump(asset_manager_response), status: 201)

      expect(document.attachments.count).to eq(2)

      delete :destroy, params: {
        document_type_slug:,
        document_content_id_and_locale: "#{document_content_id}:#{document_locale}",
        attachment_content_id:,
      }

      expect(document.attachments.count).to eq(1)
      expect(response).to redirect_to(edit_document_path(
                                        document_type_slug:,
                                        content_id_and_locale: "#{document_content_id}:#{document_locale}",
                                      ))
    end
  end
end
