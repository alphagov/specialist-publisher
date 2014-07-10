class CmaCasesController < ApplicationController

  before_filter :authorize_user

  rescue_from("SpecialistDocumentRepository::NotFoundError") do
    # TODO: Remove use of exceptions for flow control.
    redirect_to(manuals_path, flash: { error: "Document not found" })
  end

  def index
    documents = services.list_documents.call

    render(:index, locals: { documents: documents })
  end

  def show
    document = services.show_document(document_id).call

    render(:show, locals: { document: document })
  end

  def new
    document = services.new_document.call

    render(:new, locals: { document: form_object_for(document) })
  end

  def edit
    document = services.show_document(document_id).call

    render(:edit, locals: { document: form_object_for(document) })
  end

  def create
    document = services.create_document(document_params).call

    if document.valid?
      redirect_to(cma_case_path(document))
    else
      render(:new, locals: {document: document})
    end
  end

  def update
    document = services.update_document(document_id, document_params).call

    if document.valid?
      redirect_to(cma_case_path(document))
    else
      render(:edit, locals: {document: document})
    end
  end

  def publish
    document = services.publish_document(document_id).call

    redirect_to(cma_case_path(document), flash: { notice: "Published #{document.title}" })
  end

  def withdraw
    document = services.withdraw_document(document_id).call

    redirect_to(cma_case_path(document), flash: { notice: "Withdrawn #{document.title}" })
  end

  def preview
    preview_html = services.preview_document(params.fetch("id", nil), document_params).call

    render json: { preview_html: preview_html }
  end

protected

  def form_object_for(document)
    CmaCaseForm.new(document)
  end

  def authorize_user
    unless user_can_edit_cma_cases?
      redirect_to manuals_path, flash: { error: "You don't have permission to do that." }
    end
  end

  def document_id
    params.fetch("id")
  end

  def document_params
    params.fetch("cma_case", {})
  end
end
