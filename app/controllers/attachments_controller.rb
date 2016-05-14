class AttachmentsController < ApplicationController
  before_action :check_authorisation, if: :document_type_slug

  def check_authorisation
    authorize current_format
  end

  def new
    @document = fetch_document
    @attachment = Attachment.new
  end

  def create
    attachment = Attachment.new(attachment_params)
    document = fetch_document
    attachment.content_type = attachment.file.content_type

    if upload_attachment(attachment, document)
      flash[:success] = "Attached #{attachment.title}"
      redirect_to edit_document_path(document_type_slug, document.content_id)
    else
      flash[:danger] = "There was an error uploading the attachment, please try again later."
      redirect_to new_document_attachment_path(document_type_slug, document.content_id)
    end
  end

  def edit
    @document = fetch_document
    @attachment = @document.find_attachment(attachment_content_id)
  end

  def update
    document = fetch_document
    attachment = document.find_attachment(attachment_content_id)
    attachment.update_attributes(attachment_params)

    if upload_attachment(attachment, document)
      flash[:success] = "Attachment succesfully updated"
      redirect_to edit_document_path(document_type_slug, document.content_id)
    else
      flash[:danger] = "There was an error uploading the attachment, please try again later."
      redirect_to edit_document_attachment_path(document_type_slug, document.content_id, attachment.content_id)
    end
  end

private

  def fetch_document
    current_format.find(params[:document_content_id]).tap do |document|
      document.update_type = "minor"
    end
  rescue Document::RecordNotFound => e
    flash[:danger] = "Document not found"
    redirect_to documents_path(document_type_slug: document_type_slug)

    Airbrake.notify(e)
  end

  def attachment_content_id
    params[:attachment_content_id]
  end

  def upload_attachment(attachment, document)
    AttachmentUploader.new.upload(attachment, document)
  end

  def attachment_params
    params.require(:attachment).permit(:title, :file)
  end
end
