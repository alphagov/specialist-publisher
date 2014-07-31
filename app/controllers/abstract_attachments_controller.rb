class AbstractAttachmentsController < ApplicationController

  def new
    document, attachment = services.new(document_id).call

    render("attachments/new", locals: {
      document: view_adapter(document),
      attachment: attachment,
    })
  end

  def create
    document, attachment = services.create(self, document_id).call

    redirect_to(edit_path(document))
  end

  def edit
    document, attachment = services.show(self, document_id).call

    render("attachments/edit", locals: {
      document: view_adapter(document),
      attachment: attachment,
    })
  end

  def update
    document, attachment = services.update(self, document_id).call

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
