class SpecialistDocumentsController < ApplicationController

  def index; end

  def new; end

  def edit; end

  def create
    specialist_document_registry.store!(document)
    redirect_to specialist_documents_path
  rescue SpecialistDocumentRegistry::InvalidDocumentError => e
    @document = e.document
    render :new
  end

  def update
    specialist_document_registry.store!(document)
    specialist_document_registry.publish!(document) if params.has_key?('publish')
    redirect_to specialist_documents_path
  rescue SpecialistDocumentRegistry::InvalidDocumentError => e
    @document = e.document
    render :edit
  end

protected

  def document
    @document ||= begin
      if params[:id]
        current_document = specialist_document_registry.fetch(params[:id])

        if current_document && params[:specialist_document]
          SpecialistDocument.new(params[:specialist_document].merge(id: current_document.id))
        else
          current_document
        end
      else
        SpecialistDocument.new(params[:specialist_document])
      end
    end
  end
  helper_method :document

  def documents
    @documents ||= specialist_document_registry.all
  end
  helper_method :documents

end
