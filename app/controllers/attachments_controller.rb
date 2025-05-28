class AttachmentsController < ApplicationController
  before_action :check_authorisation, if: :document_type_slug

  layout :get_layout
  DESIGN_SYSTEM_MIGRATED_ACTIONS = %w[new edit].freeze
  include DesignSystemHelper

  def check_authorisation
    authorize current_format
  end

  def new
    @document = fetch_document
    @attachment = Attachment.new
    render design_system_view(:new, "attachments/legacy/new_legacy")
  end

  def create
    document = fetch_document
    if attachment_valid?

      attachment = document.attachments.build(attachment_params)
      attachment.content_type = attachment.file.content_type

      upload_attachment(document, attachment)
    else
      failed_to_attach(document)
    end
  end

  def edit
    @document = fetch_document
    @attachment = @document.attachments.find(attachment_content_id)
    render design_system_view(:edit, "attachments/legacy/edit_legacy")
  end

  def update
    document = fetch_document
    attachment = document.attachments.find(attachment_content_id)
    attachment.update_properties(attachment_params)

    if attachment.file.nil?
      save_updated_title(document, attachment)
    elsif white_listed?
      update_attachment(document, attachment)
    else
      failed_to_attach(document)
    end
  end

  def destroy
    document = fetch_document
    attachment = document.attachments.find(attachment_content_id)

    delete_attachment(document, attachment)
  end

private

  def flag_updated(document, attachment)
    updated_attachment = document.attachments.find(attachment.content_id)
    updated_attachment.being_updated = true
  end

  def save_updated_title(document, attachment)
    flag_updated(document, attachment)
    if document.save(validate: false)
      flash[:success] = "Attachment successfully updated"
      redirect_to edit_document_path(document_type_slug, document.content_id_and_locale)
    else
      flash[:danger] = "There was an error updating the title, please try again later."
      redirect_to edit_document_attachment_path(document_type_slug, document.content_id_and_locale, attachment.content_id)
    end
  end

  def update_attachment(document, attachment)
    flag_updated(document, attachment)
    if document.update_attachment(attachment)
      flash[:success] = "Updated #{attachment.title}"
      redirect_to edit_document_path(document_type_slug, document.content_id_and_locale)
    else
      flash[:danger] = "There was an error updating the attachment, please try again later."
      redirect_to edit_document_attachment_path(document_type_slug, document.content_id_and_locale, attachment.content_id)
    end
  end

  def upload_attachment(document, attachment)
    if document.upload_attachment(attachment)
      flash[:success] = "Attached #{attachment.title}"
      redirect_to edit_document_path(document_type_slug, document.content_id_and_locale)
    else
      flash[:danger] = "There was an error uploading the attachment, please try again later."
      redirect_to new_document_attachment_path(document_type_slug, document.content_id_and_locale)
    end
  end

  def delete_attachment(document, attachment)
    if document.delete_attachment(attachment)
      flash[:success] = "Attachment successfully removed"
    else
      flash[:danger] = "There was an error removing your attachment, please try again later."
    end
    redirect_to edit_document_path(document_type_slug, document.content_id_and_locale)
  end

  def fetch_document
    content_id, locale = params[:document_content_id_and_locale].split(":")
    document = current_format.find(content_id, locale)
    document.set_temporary_update_type!
    document
  rescue DocumentFinder::RecordNotFound => e
    flash[:danger] = "Document not found"
    redirect_to documents_path(document_type_slug:)

    GovukError.notify(e)
  end

  def attachment_content_id
    params[:attachment_content_id]
  end

  def attachment_params
    params.require(:attachment).permit(:title, :file).to_h
  end

  def attachment_valid?
    attachment = params["attachment"]
    attachment.present? && attachment["file"].present? && white_listed?
  end

  def white_listed?
    Attachment.valid_filetype?(params["attachment"]["file"])
  end

  def failed_to_attach(document)
    flash[:danger] = "Adding an attachment failed. Please make sure you have uploaded an attachment of a permitted file type."
    redirect_to new_document_attachment_path(document_type_slug, document.content_id_and_locale)
  end
end
