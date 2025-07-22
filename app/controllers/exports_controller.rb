class ExportsController < ApplicationController
  before_action :check_authorisation, if: :document_type_slug

  def check_authorisation
    if current_format
      authorize current_format
    else
      flash[:danger] = "That format doesn't exist. If you feel you've reached this in error, please contact your main GDS contact."
      redirect_to root_path
    end
  end

  def show
    @query = params[:query]
  end

  def create
    @query = params[:query]
    DocumentListExportWorker.perform_async(current_format.admin_slug, current_user.id.to_s, @query)
    flash[:success] = "The document list is being exported"
    redirect_to documents_path(current_format.admin_slug, query: @query)
  end
end
