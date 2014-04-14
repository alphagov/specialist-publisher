require "govspeak"

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
    document = new_document(form_params)

    store_and_redirect(document, :new)
  end

  def update
    document = current_document
    document.update(form_params)

    store_and_redirect(document, :edit)
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

  def store_and_redirect(document, error_action_name)
    if store(document, publish: params.has_key?('publish'))
      redirect_to specialist_documents_path
    else
      render(error_action_name, locals: {document: document})
    end
  end

  def store(document, publish: false)
    stored_ok = specialist_document_repository.store!(document)
    if stored_ok && publish
      specialist_document_repository.publish!(document)
    end
    stored_ok
  end

  def form_params
    params.fetch(:specialist_document, {})
  end

  def build_from_params
    specialist_document_builder.call(form_params)
  end
end
