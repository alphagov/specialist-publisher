class SpecialistDocumentsController < ApplicationController

  def index; end

  def new; end

  def edit; end

  def create
    SpecialistDocumentRegistry.store!(document)
    redirect_to specialist_documents_path
  rescue SpecialistDocumentRegistry::InvalidDocumentError => e
    @document = e.document
    render :new
  end

  def update
    SpecialistDocumentRegistry.store!(document)
    SpecialistDocumentRegistry.publish!(document) if params.has_key?('publish')
    redirect_to specialist_documents_path
  rescue SpecialistDocumentRegistry::InvalidDocumentError => e
    @document = e.document
    render :edit
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

  def documents
    @documents ||= SpecialistDocumentRegistry.all
  end
  helper_method :documents

end
