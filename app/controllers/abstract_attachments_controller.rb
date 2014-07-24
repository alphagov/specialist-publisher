class AbstractAttachmentsController < ApplicationController

  def new
    document, attachment = services.new_attachment(document_id).call

    render("attachments/new", locals: {
      document: view_adapter(document),
      attachment: attachment,
    })
  end

  def create
    document, attachment = services.create_attachment(self, document_id).call

    redirect_to(edit_path(document))
  end

  def edit
    # TODO: action not tested
    document, attachment = services.show_attachment(self, document_id).call

    render("attachments/edit", locals: {
      document: view_adapter(document),
      attachment: attachment,
    })
  end

  def update
    document, attachment = services.update_attachment(self, document_id).call

    if attachment.persisted?
      redirect_to(edit_path(document))
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

  def services
    raise NotImplementedError
  end

  def edit_path(document)
    raise NotImplementedError
  end
end
