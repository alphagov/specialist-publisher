class DrugSafetyUpdateAttachmentsController < AbstractAttachmentsController

private
  def view_adapter(document)
    DrugSafetyUpdateViewAdapter.new(document)
  end

  def document_id
    params.fetch("drug_safety_update_id")
  end

  def services
    DrugSafetyUpdateAttachmentServiceRegistry.new
  end

  def edit_path(document)
    edit_drug_safety_update_path(document)
  end
end
