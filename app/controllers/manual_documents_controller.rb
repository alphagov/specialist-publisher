class ManualDocumentsController < ApplicationController
  def show
    manual, document = services.show(self).call

    render(:show, locals: {
      manual: manual,
      document: document,
    })
  end

  def new
    manual, document = services.new(self).call

    render(:new, locals: {
      manual: ManualViewAdapter.new(manual),
      document: ManualDocumentViewAdapter.new(manual, document)
    })
  end

  def create
    manual, document = services.create(self).call

    if document.valid?
      redirect_to(manual_path(manual))
    else
      render(:new, locals: {
        manual: ManualViewAdapter.new(manual),
        document: ManualDocumentViewAdapter.new(manual, document),
      })
    end
  end

  def edit
    manual, document = services.show(self).call

    render(:edit, locals: {
      manual: ManualViewAdapter.new(manual),
      document: ManualDocumentViewAdapter.new(manual, document),
    })
  end

  def update
    manual, document = services.update(self).call

    if document.valid?
      redirect_to(manual_path(manual))
    else
      render(:edit, locals: {
        manual: ManualViewAdapter.new(manual),
        document: ManualDocumentViewAdapter.new(manual, document),
      })
    end
  end

  def preview
    document = services.preview(self).call

    document.valid? # Force validation check or errors will be empty

    if document.errors[:body].nil?
      render json: { preview_html: document.body }
    else
      render json: {
        preview_html: render_to_string(
          "shared/_preview_errors",
          layout: false,
          locals: {
            errors: document.errors[:body]
          }
        )
      }
    end
  end

  def reorder
    manual, documents = services.list(self).call

    render(:reorder, locals: {
      manual: ManualViewAdapter.new(manual),
      documents: documents,
    })
  end

  def update_order
    manual, documents = services.update_order(self).call

    redirect_to(
      manual_path(manual),
      flash: {
        notice: "Order of sections saved for #{manual.title}",
      },
    )
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
    ManualDocumentServiceRegistry.new
  end

  def organisational_services
    OrganisationalManualDocumentServiceRegistry.new(
      organisation_slug: current_organisation_slug,
    )
  end
end
