class ManualDocumentAttachmentsController < ApplicationController
  def new
    manual, document, attachment = services.new(self).call

    render(:new, locals: {
      manual: ManualViewAdapter.new(manual),
      document: ManualDocumentViewAdapter.new(manual, document),
      attachment: attachment,
    })
  end

  def create
    manual, document, attachment = services.create(self).call

    redirect_to edit_manual_document_path(manual, document)
  end

  def edit
    manual, document, attachment = services.show(self).call

    render(:edit, locals: {
      manual: ManualViewAdapter.new(manual),
      document: ManualDocumentViewAdapter.new(manual, document),
      attachment: attachment,
    })
  end

  def update
    manual, document, attachment = services.update(self).call

    if attachment.persisted?
      redirect_to(edit_manual_document_path(manual, document))
    else
      render(:edit, locals: {
        manual: ManualViewAdapter.new(manual),
        document: ManualDocumentViewAdapter.new(manual, document),
        attachment: attachment,
      })
    end
  end

private
  def services
    if current_user_is_gds_editor?
      gds_editor_services
    else
      organisational_services
    end
  end

  def gds_editor_services
    ManualDocumentAttachmentServiceRegistry.new
  end

  def organisational_services
    OrganisationalManualDocumentAttachmentServiceRegistry.new(
      organisation_slug: current_organisation_slug,
    )
  end
end
