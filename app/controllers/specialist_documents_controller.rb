class SpecialistDocumentsController < ApplicationController

  def index; end

  def new; end

  def edit; end

  def create
    if store(document, publish: params.has_key?('publish'))
      redirect_to specialist_documents_path
    else
      @document = document
      render :new
    end
  end

  def update
    if store(document, publish: params.has_key?('publish'))
      redirect_to specialist_documents_path
    else
      @document = document
      render :edit
    end
  end

protected

  def document
    @document ||= begin
      if params[:id]
        current_document = specialist_document_registry.fetch(params[:id])

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
    @documents ||= specialist_document_registry.all
  end
  helper_method :documents

  def store(document, publish: false)
    specialist_document_registry.store!(document).tap {
      specialist_document_registry.publish!(document) if publish
    }
  end
end
