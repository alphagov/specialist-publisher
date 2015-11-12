class DocumentsController <  ApplicationController

  def index
    redirect_to "/#{document_types.keys.first}" unless params[:document_type]
  end

end
