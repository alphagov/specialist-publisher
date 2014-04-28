require "govspeak"
require_relative "../services/publish_document_service"
require_relative "../services/update_document_service"

class SpecialistDocumentsController < ApplicationController

  def index
    render_with(documents: all_documents)
  end

  def new
    render_with(document: new_document({}))
  end

  def edit
    render_with(document: current_document)
  end

  def create
    document = services.create_document(self).call

    if document.valid? && publish_document?
      services.publish_document(document).call
    end

    if document.valid?
      redirect_to(specialist_documents_path)
    else
      render(:new, locals: {document: document})
    end
  end

  def update
    document = services.update_document(self).call

    if document.valid? && publish_document?
      services.publish_document(document).call
    end

    if document.valid?
      redirect_to(specialist_documents_path)
    else
      render(:edit, locals: {document: document})
    end
  end

  def preview
    render json: { preview_html: generate_preview }
  end

protected

  def publish_document?
    params.has_key?("publish")
  end

  def all_documents
    specialist_document_repository.all
  end

  def new_document(doc_params)
    specialist_document_builder.call(doc_params)
  end

  def current_document
    specialist_document_repository.fetch(params.fetch(:id))
  end

  def generate_preview
    if current_document
      preview_document = current_document.update(form_params)
    else
      preview_document = build_from_params
    end

    specialist_document_renderer.call(preview_document).body
  end

  def form_params
    params.fetch(:specialist_document, {})
  end

  def build_from_params
    specialist_document_builder.call(form_params)
  end
end
