class AaibReportsAttachmentsController < ApplicationController
  def new
    document, attachment = aaib_report_attachment_services.new_aaib_report_attachment(document_id).call

    render("attachments/new", locals: {
      document: document,
      attachment: attachment,
    })
  end

  def create
    document, attachment = aaib_report_attachment_services.create_aaib_report_attachment(self, document_id).call

    redirect_to edit_aaib_report_path(document)
  end

  def edit
    # TODO: action not tested
    document, attachment = aaib_report_attachment_services.show_aaib_report_attachment(self, document_id).call

    render("attachments/edit", locals: {
      document: document,
      attachment: attachment,
    })
  end

  def update
    document, attachment = aaib_report_attachment_services.update_aaib_report_attachment(self, document_id).call

    if attachment.persisted?
      redirect_to(edit_aaib_report_path(document))
    else
      render("attachments/edit", locals: {
        document: document,
        attachment: attachment,
      })
    end
  end

protected

  def document_id
    params.fetch("aaib_report_id")
  end
end
