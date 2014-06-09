class ManualDocumentsController < ApplicationController
  def show
    manual, document = services.show_manual_document(self).call

    render(:show, locals: {
      manual: manual,
      document: document,
    })
  end

  def new
    manual, document = services.new_manual_document(self).call

    render(:new, locals: {
      manual: ManualForm.new(manual),
      document: ManualDocumentForm.new(manual, document)
    })
  end

  def create
    manual, document = services.create_manual_document(self).call

    if document.valid?
      redirect_to(manual_path(manual))
    else
      # TODO: this branch is untested
      render(:new, locals: {
        manual: ManualForm.new(manual),
        document: ManualDocumentForm.new(manual, document),
      })
    end
  end

  def edit
    manual, document = services.show_manual_document(self).call

    render(:edit, locals: {
      manual: ManualForm.new(manual),
      document: ManualDocumentForm.new(manual, document),
    })
  end

  def update
    manual, document = services.update_manual_document(self).call

    if document.valid?
      redirect_to(manual_path(manual))
    else
      render(:edit, locals: {
        manual: ManualForm.new(manual),
        document: ManualDocumentForm.new(manual, document),
      })
    end
  end

  def preview
    preview_html = services.preview_manual_document(self).call

    render json: { preview_html: preview_html }
  end
end
