class AbstractAttachmentsController < ApplicationController

protected
  def view_adapter(document)
    raise NotImplementedError
  end

  def document_id
    raise NotImplementedError
  end

end
