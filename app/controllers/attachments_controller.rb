class AttachmentsController < ApplicationController
  def new; end

  def create
    specialist_document.add_attachment(params[:attachment])
    specialist_document_repository.store!(specialist_document)
    redirect_to edit_specialist_document_path(specialist_document)
  end

private

  def specialist_document
    @specialist_document ||= specialist_document_repository.fetch(params[:specialist_document_id])
  end
  helper_method :specialist_document
end
