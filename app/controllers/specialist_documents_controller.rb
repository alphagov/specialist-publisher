require "govspeak"

class SpecialistDocumentsController < ApplicationController

  def index; end

  def new; end

  def edit
  end

  def create
    if preview_requested?
      display_preview
    else
      store_or_redirect(:new)
    end
  end

  def update
    if preview_requested?
      display_preview
    else
      store_or_redirect(:edit)
    end
  end

  def preview
    render json: { preview_html: generate_preview }
  end

protected

  def preview_requested?
    params.has_key?(:preview)
  end

  def display_preview
    @preview = generate_preview
    render :edit
  end

  def store_or_redirect(action_name)
    if store(document, publish: params.has_key?('publish'))
      redirect_to specialist_documents_path
    else
      @document = document
      render action_name
    end
  end

  def document
    @document ||= begin
      if params[:id]
        current_document = specialist_document_repository.fetch(params[:id])

        if current_document && params[:specialist_document]
          current_document.update(params[:specialist_document])
        else
          current_document
        end
      else
        specialist_document_builder.call(params.fetch(:specialist_document, {}))
      end
    end
  end
  helper_method :document

  def documents
    @documents ||= specialist_document_repository.all
  end
  helper_method :documents

  def store(document, publish: false)
    stored_ok = specialist_document_repository.store!(document)
    if stored_ok && publish
      specialist_document_repository.publish!(document)
    end
    stored_ok
  end

  def generate_preview
    Govspeak::Document.new(document.body).to_html
  end
end
