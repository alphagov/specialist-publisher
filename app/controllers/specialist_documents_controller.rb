class SpecialistDocumentsController < ApplicationController

  def index; end

  def new; end

  def edit; end

  def create
    if document.valid?
      SpecialistDocumentRegistry.store(document)
      redirect_to specialist_documents_path
    else
      render :new
    end
  end

  def update
    if document.valid?
      SpecialistDocumentRegistry.store(document)
      redirect_to specialist_documents_path
    else
      render :edit
    end
  end

protected

  def document
    @document ||= if params[:id]
      SpecialistDocumentRegistry.fetch(params[:id])
    else
      SpecialistDocument.new(params[:specialist_document])
    end
  end
  helper_method :document

end
