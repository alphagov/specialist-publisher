class CmaCaseAttachmentsController < AbstractAttachmentsController
  def new
    document, attachment = attachment_services.new_attachment(document_id).call

    render("attachments/new", locals: {
      document: view_adapter(document),
      attachment: attachment,
    })
  end

  def create
    document, attachment = attachment_services.create_attachment(self, document_id).call

    redirect_to edit_cma_case_path(document)
  end

  def edit
    # TODO: action not tested
    document, attachment = attachment_services.show_attachment(self, document_id).call

    render("attachments/edit", locals: {
      document: view_adapter(document),
      attachment: attachment,
    })
  end

  def update
    document, attachment = attachment_services.update_attachment(self, document_id).call

    if attachment.persisted?
      redirect_to(edit_cma_case_path(document))
    else
      render("attachments/edit", locals: {
        document: view_adapter(document),
        attachment: attachment,
      })
    end
  end

protected
  def view_adapter(document)
    CmaCaseViewAdapter.new(document)
  end

  def document_id
    params.fetch("cma_case_id")
  end

  def attachment_services
    SpecialistPublisherWiring.get(:cma_case_attachment_services)
  end
end
