class ManualDocumentsAttachmentsController < ApplicationController
  def new
    render(:new, locals: {
      manual: manual,
      document: document,
      # TODO: This be should be created from the document or just be a form object
      attachment: Attachment.new,
    })
  end

  def create
    document.add_attachment(params[:attachment])
    manual_document_repository.store(document)
    redirect_to edit_manual_document_path(parent_manual, document)
  end

  def edit
    render(:edit, locals: {
      manual: manual,
      document: document,
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
      redirect_to(edit_manual_document_path(parent_manual, document))
    else
      render(:edit, locals: {
        manual: manual,
        document: document,
        attachment: attachment,
      })
    end
  end

private

  def parent_manual
    @parent_manual ||= manual_repository.fetch(manual_id)
  end

  def manual
    ManualForm.new(parent_manual)
  end

  def document
    @document ||= ManualDocumentForm.new(parent_manual, parent_manual.documents.find { |d| d.id == document_id })
  end

  def existing_attachment
    document.find_attachment_by_id(attachment_id)
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

  def manual_id
    params.fetch("manual_id")
  end

  def document_id
    params.fetch("document_id")
  end
end
