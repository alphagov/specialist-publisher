class AttachmentsController < ApplicationController
  def new
    document, attachment = services.new_document_attachment(document_id).call

    render(:new, locals: {
      document: document,
      attachment: attachment,
    })
  end

  def create
    document, attachment = services.create_document_attachment(self, document_id).call

    redirect_to edit_specialist_document_path(document)
  end

  def edit
    # TODO: action not tested
    document, attachment = services.show_document_attachment(self, document_id).call

    render(:edit, locals: {
      document: document,
      attachment: attachment,
    })
  end

  def update
    document, attachment = services.update_document_attachment(self, document_id).call

    if attachment.persisted?
      redirect_to(edit_specialist_document_path(document))
    else
      render(:edit, locals: {
        document: document,
        attachment: attachment,
      })
    end
  end

protected

  def document_id
    params.fetch("specialist_document_id")
  end
end
