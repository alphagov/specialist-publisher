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
      manual: ManualViewAdapter.new(manual),
      document: ManualDocumentViewAdapter.new(manual, document)
    })
  end

  def create
    manual, document = services.create_manual_document(self).call

    if document.valid?
      redirect_to(manual_path(manual))
    else
      render(:new, locals: {
        manual: ManualViewAdapter.new(manual),
        document: ManualDocumentViewAdapter.new(manual, document),
      })
    end
  end

  def edit
    manual, document = services.show_manual_document(self).call

    render(:edit, locals: {
      manual: ManualViewAdapter.new(manual),
      document: ManualDocumentViewAdapter.new(manual, document),
    })
  end

  def update
    manual, document = services.update_manual_document(self).call

    if document.valid?
      redirect_to(manual_path(manual))
    else
      render(:edit, locals: {
        manual: ManualViewAdapter.new(manual),
        document: ManualDocumentViewAdapter.new(manual, document),
      })
    end
  end

  def preview
    document = services.preview_manual_document(self).call

    document.valid? # Force validation check or errors will be empty

    if document.errors[:body].nil?
      render json: { preview_html: document.body }
    else
      render json: {
        preview_html: render_to_string(
          "specialist_documents/_preview_errors",
          layout: false,
          locals: {
            errors: document.errors[:body]
          }
        )
      }
    end
  end
end
