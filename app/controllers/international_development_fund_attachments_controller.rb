class InternationalDevelopmentFundAttachmentsController < AbstractAttachmentsController

private
  def view_adapter(document)
    InternationalDevelopmentFundViewAdapter.new(document)
  end

  def document_id
    params.fetch("international_development_fund_id")
  end

  def services
    InternationalDevelopmentFundAttachmentServiceRegistry.new
  end

  def edit_path(document)
    edit_international_development_fund_path(document)
  end
end
