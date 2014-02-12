class SpecialistDocumentsController < ApplicationController

  def index; end

  def new; end

  def edit; end

  def create
    store_document_and_redirect(fallback_action: 'new')
  end

  def update
    store_document_and_redirect(fallback_action: 'edit')
  end

protected

  def store_document_and_redirect(fallback_action: 'index')
    SpecialistDocumentRegistry.store!(document)
    redirect_to specialist_documents_path
  rescue SpecialistDocumentRegistry::InvalidDocumentError => e
    @document = e.document
    render fallback_action
  end

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
