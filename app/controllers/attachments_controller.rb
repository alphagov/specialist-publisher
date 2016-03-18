class AttachmentsController < ApplicationController
  def new
    @attachment = Attachment.new
  end

  def create
    attachment = Attachment.new(params[:attachment])
    document = fetch_document

    if document.upload(attachment) && document.save!
      flash[:success] = "Attached #{attachment.title}"
      redirect_to edit_document_path(params[:document_type], document.content_id)
    else
      flash[:danger] = "There was an error uploading the attachment, please try again later."
      redirect_to new_document_attachment_path(params[:document_type], document.content_id)
    end
  end

  def edit
    document = fetch_document
    @attachment = document.find_attachment(params[:attachment_content_id])
  end

  private
  def fetch_document
    begin
      @document = document_klass.find(params[:document_content_id])
    rescue Document::RecordNotFound => e
      flash[:danger] = "Document not found"
      redirect_to documents_path(document_type: document_type)

      Airbrake.notify(e)
    end
  end

  def document_klass
    current_format.klass
  end
end