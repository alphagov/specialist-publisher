class AaibReportsController < ApplicationController

  before_filter :authorize_user

  rescue_from("SpecialistDocumentRepository::NotFoundError") do
    # TODO: Remove use of exceptions for flow control.
    redirect_to(manuals_path, flash: { error: "Document not found" })
  end

  def index
    documents = services.list_aaib_reports.call

    render(:index, locals: { documents: documents })
  end

  def show
    document = services.show_aaib_report(params.fetch("id")).call

    render(:show, locals: { document: document })
  end

  def new
    document = services.new_aaib_report.call

    render(:new, locals: { document: form_object_for(document) })
  end

  def edit
    document = services.show_aaib_report(params.fetch("id")).call

    render(:edit, locals: { document: form_object_for(document) })
  end

  def create
    document = services.create_aaib_report(params.fetch("aaib_report", {})).call

    if document.valid?
      redirect_to(aaib_report_path(document))
    else
      render(:new, locals: { document: document })
    end
  end

  def update
    document = services.update_aaib_report(params.fetch("id"), params.fetch("aaib_report", {})).call

    if document.valid?
      redirect_to(aaib_report_path(document))
    else
      render(:edit, locals: { document: document })
    end
  end

  def publish
    document = services.publish_aaib_report(params.fetch("id")).call

    redirect_to(aaib_report_path(document), flash: { notice: "Published #{document.title}" })
  end

  def withdraw
    document = services.withdraw_aaib_report(params.fetch("id")).call

    redirect_to(aaib_reports_path, flash: { notice: "Withdrawn #{document.title}" })
  end

  def preview
    preview_html = services.preview_aaib_report(params.fetch("id", nil), params.fetch("aaib_report", {})).call

    render json: { preview_html: preview_html }
  end

protected

  def form_object_for(document)
    AaibReportForm.new(document)
  end

  def authorize_user
    unless user_can_edit_aaib_reports?
      redirect_to manuals_path, flash: { error: "You don't have permission to do that." }
    end
  end
end
