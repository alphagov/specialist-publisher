class ManualDocumentsAttachmentsController < ApplicationController
  def new
    manual, document, attachment = services.new_manual_document_attachment(self).call

    render(:new, locals: {
      manual: ManualViewAdapter.new(manual),
      document: ManualDocumentViewAdapter.new(manual, document),
      attachment: attachment,
    })
  end

  def create
    manual, document, attachment = services.create_manual_document_attachment(self).call

    redirect_to edit_manual_document_path(manual, document)
  end

  def edit
    # TODO: action not tested
    manual, document, attachment = services.show_manual_document_attachment(self).call

    render(:edit, locals: {
      manual: ManualViewAdapter.new(manual),
      document: ManualDocumentViewAdapter.new(manual, document),
      attachment: attachment,
    })
  end

  def update
    manual, document, attachment = services.update_manual_document_attachment(self).call

    if attachment.persisted?
      redirect_to(edit_manual_document_path(manual, document))
    else
      render(:edit, locals: {
        manual: ManualViewAdapter.new(manual),
        document: ManualDocumentViewAdapter.new(manual, document),
        attachment: attachment,
      })
    end
  end
end
