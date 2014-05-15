class ManualDocumentsController < ApplicationController
  def show
    render_with(
      manual: parent_manual,
      document: current_document,
    )
  end

  def new
    render_with(
      manual: ManualForm.new(parent_manual),
      document: ManualDocumentForm.new(parent_manual)
    )
  end

  def create
    document = specialist_document_builder.call(document_params)

    document = ManualDocumentForm.new(parent_manual, document)
    if document.valid?
      parent_manual.add_document(document)

      manual_repository.store(parent_manual)

      redirect_to(manual_path(parent_manual))
    else
      render(:new, locals: {
        manual: ManualForm.new(parent_manual),
        document: ManualDocumentForm.new(parent_manual, document),
      })
    end
  end

  def edit
    render_with(
      manual: ManualForm.new(parent_manual),
      document: ManualDocumentForm.new(parent_manual, current_document),
    )
  end

  def update
    current_document.update(document_params)

    if current_document.valid?
      manual_repository.store(parent_manual)
      redirect_to(manual_path(parent_manual))
    else
      render(:edit, locals: {
        manual: ManualForm.new(parent_manual),
        document: ManualDocumentForm.new(parent_manual, current_document),
      })
    end
  end

  def preview
    render json: { preview_html: generate_preview }
  end

private

  def new_document
    @new_document ||= specialist_document_builder.call({})
  end

  def parent_manual
    @parent_manual ||= manual_repository.fetch(manual_id)
  end

  def current_document
    @current_document ||= parent_manual.documents.find { |d| d.id == document_id }
  end

  def manual_id
    params.fetch("manual_id")
  end

  def document_id
    params.fetch("id", nil)
  end

  def document_params
    params.fetch("document", {}).merge(document_type: 'manual')
  end

  def generate_preview
    if current_document
      preview_document = current_document.update(document_params)
    else
      preview_document = specialist_document_builder.call(document_params)
    end

    specialist_document_renderer.call(preview_document).body
  end
end
