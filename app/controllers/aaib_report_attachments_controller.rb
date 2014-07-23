class AaibReportAttachmentsController < AbstractAttachmentsController
  def new
    document, attachment = attachment_services.new_attachment(document_id).call

    render("attachments/new", locals: {
      document: view_adapter(document),
      attachment: attachment,
    })
  end

  def create
    document, attachment = attachment_services.create_attachment(self, document_id).call

    redirect_to edit_aaib_report_path(document)
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
      redirect_to(edit_aaib_report_path(document))
    else
      render("attachments/edit", locals: {
        document: view_adapter(document),
        attachment: attachment,
      })
    end
  end

protected

  def view_adapter(document)
    AaibReportViewAdapter.new(document)
  end

  def document_id
    params.fetch("aaib_report_id")
  end

  def attachment_services
    SpecialistPublisherWiring.get(:aaib_report_attachment_services)
  end
end
