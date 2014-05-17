class AttachmentsController < ApplicationController
  def new
    render(:new, locals: {
      specialist_document: specialist_document,
      # TODO: This be should be created from the document or just be a form object
      attachment: Attachment.new,
    })
  end

  def create
    specialist_document.add_attachment(params[:attachment])
    specialist_document_repository.store(specialist_document)
    redirect_to edit_specialist_document_path(specialist_document)
  end

  def edit
    render(:edit, locals: {
      specialist_document: specialist_document,
      attachment: existing_attachment,
    })
  end

  def update
    attachment = existing_attachment
    update_result = attachment.update_attributes(
      params.fetch(:attachment).merge(
        # TODO: move this into content models as a persistence concern
        filename: uploaded_filename,
      )
    )

    if update_result
      redirect_to(edit_specialist_document_path(specialist_document))
    else
      render(:edit, locals: {
        specialist_document: specialist_document,
        attachment: attachment,
      })
    end
  end

private

  def specialist_document
    @specialist_document ||= specialist_document_repository.fetch(params.fetch(:specialist_document_id))
  end

  def existing_attachment
    specialist_document.find_attachment_by_id(attachment_id)
  end

  def attachment_id
    params.fetch(:id)
  end

  def uploaded_filename
    params
      .fetch(:attachment)
      .fetch(:file)
      .original_filename
  end
end
