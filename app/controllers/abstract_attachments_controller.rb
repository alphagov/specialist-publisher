class AbstractAttachmentsController < ApplicationController

  def new
    document, attachment = attachment_services.new_attachment(document_id).call

    render("attachments/new", locals: {
      document: view_adapter(document),
      attachment: attachment,
    })
  end

  def create
    document, attachment = attachment_services.create_attachment(self, document_id).call

    redirect_to(redirect_path(document))
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
      redirect_to(redirect_path(document))
    else
      render("attachments/edit", locals: {
        document: view_adapter(document),
        attachment: attachment,
      })
    end
  end

private
  def view_adapter(document)
    raise NotImplementedError
  end

  def document_id
    raise NotImplementedError
  end

  def attachment_services
    raise NotImplementedError
  end

  def redirect_path(document)
    root_path
  end
end
