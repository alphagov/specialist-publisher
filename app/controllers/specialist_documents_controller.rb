require "govspeak"
require_relative "../services/publish_document_service"
require_relative "../services/update_document_service"

class SpecialistDocumentsController < ApplicationController

  before_filter :authorize_user_org

  rescue_from(KeyError) do
    redirect_to(manuals_path, flash: { error: "Document not found" })
  end

  def index
    render(:index, locals: { documents: all_documents })
  end

  def show
    render(:show, locals: { document: current_document })
  end

  def new
    render(:new, locals: { document: new_document({}) })
  end

  def edit
    render(:edit, locals: { document: current_document })
  end

  def create
    document = services.create_document(self).call

    if document.valid?
      redirect_to(specialist_document_path(document))
    else
      render(:new, locals: {document: document})
    end
  end

  def update
    document = services.update_document(self).call

    if document.valid?
      redirect_to(specialist_document_path(document))
    else
      render(:edit, locals: {document: document})
    end
  end

  def publish
    services.publish_document(current_document).call

    redirect_to(specialist_document_path(current_document))
  end

  def withdraw
    document = services.withdraw_document(self).call

    redirect_to(specialist_documents_path)
  end

  def preview
    render json: { preview_html: generate_preview }
  end

protected

  def all_documents
    specialist_document_repository.all
  end

  def new_document(doc_params)
    specialist_document_builder.call(doc_params)
  end

  def current_document
    @current_document ||= specialist_document_repository.fetch(params.fetch(:id))
  end

  def generate_preview
    if current_document
      preview_document = current_document.update(form_params)
    else
      preview_document = build_from_params
    end

    specialist_document_renderer.call(preview_document).body
  end

  def specialist_document_params
    form_params.merge(document_type: 'cma_case')
  end

  def form_params
    params.fetch(:specialist_document, {})
  end

  def build_from_params
    specialist_document_builder.call(form_params)
  end

  def authorize_user_org
    unless user_can_edit_documents?
      redirect_to manuals_path, flash: { error: "You don't have permission to do that." }
    end
  end
end
