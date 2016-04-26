class ManualSectionsAttachmentsController < ApplicationController
  before_action :check_authorisation

  def check_authorisation
    authorize :manual_section_attachment
  end

  def new
    @section = fetch_section
    @attachment = Attachment.new
  end

  def create
    attachment = Attachment.new(attachment_params)
    section = fetch_section
    attachment.content_type = attachment.file.content_type

    if upload_attachment(attachment, section)
      flash[:success] = "Attached #{attachment.title}"
      redirect_to edit_manual_section_path(section.manual_content_id, section.content_id)
    else
      flash[:danger] = "There was an error uploading the attachment, please try again later."
      redirect_to new_manual_section_attachment_path(section.manual_content_id, section.content_id)
    end
  end

  def edit
    @section = fetch_section
    @attachment = @section.find_attachment(attachment_content_id)
  end

  def update
    section = fetch_section
    attachment = section.find_attachment(attachment_content_id)
    attachment.update_attributes(attachment_params)
    if upload_attachment(attachment, section)
      flash[:success] = "Attachment succesfully updated"
      redirect_to edit_manual_section_path(section.manual_content_id, section.content_id)
    else
      flash[:danger] = "There was an error uploading the attachment, please try again later."
      redirect_to edit_manual_section_attachment_path(section.manual_content_id, section.content_id, attachment.content_id)
    end
  end

private

  def fetch_section
    Section.find(
      content_id: params[:section_content_id],
      manual_content_id: params[:manual_content_id]
    ).tap do |section|
      section.update_type = "minor"
    end
  rescue Section::RecordNotFound => e
    flash[:danger] = e.message
    redirect_to manuals_path

    Airbrake.notify(e)
  end

  def attachment_content_id
    params[:attachment_content_id]
  end

  def upload_attachment(attachment, section)
    AttachmentUploader.new.upload(attachment, section)
  end

  def attachment_params
    params.require(:attachment).permit(:title, :file)
  end
end
