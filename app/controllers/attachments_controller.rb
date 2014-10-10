class AttachmentsController < ApplicationController

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
    SpecialistPublisher.view_adapter(document)
  end

  def services
    SpecialistPublisher.attachment_services(document_type)
  end

  def edit_path(document)
    send("edit_#{document_type}_path", document)
  end

  def document_id
    params
      .select { |k, _v| k.ends_with?("_id") }
      .values
      .fetch(0)
  end

  def document_type
    params
      .select { |k, _v| k.ends_with?("_id") }
      .keys
      .fetch(0)
      .sub(/_id\z/, "")
  end
end
