require "aaib_report_service_registry"

class AaibReportsController < ApplicationController

  before_filter :authorize_user

  rescue_from("SpecialistDocumentRepository::NotFoundError") do
    redirect_to(aaib_reports_path, flash: { error: "Document not found" })
  end

  def index
    documents = services.list.call

    render(:index, locals: { documents: documents })
  end

  def show
    document = services.show(document_id).call

    render(:show, locals: { document: document })
  end

  def new
    document = services.new.call

    render(:new, locals: { document: form_object_for(document) })
  end

  def edit
    document = services.show(document_id).call

    render(:edit, locals: { document: form_object_for(document) })
  end

  def create
    document = services.create(document_params).call

    if document.valid?
      redirect_to(aaib_report_path(document))
    else
      render(:new, locals: { document: document })
    end
  end

  def update
    document = services.update(document_id, document_params).call

    if document.valid?
      redirect_to(aaib_report_path(document))
    else
      render(:edit, locals: { document: document })
    end
  end

  def publish
    document = services.publish(document_id).call

    redirect_to(aaib_report_path(document), flash: { notice: "Published #{document.title}" })
  end

  def withdraw
    document = services.withdraw(document_id).call

    redirect_to(aaib_reports_path, flash: { notice: "Withdrawn #{document.title}" })
  end

  def preview
    preview_html = services.preview(params.fetch("id", nil), document_params).call

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

  def document_id
    params.fetch("id")
  end

  def document_params
    filter_blank_multi_selects(
      params.fetch("aaib_report", {})
    ).with_indifferent_access
  end

  # See http://stackoverflow.com/questions/8929230/why-is-the-first-element-always-blank-in-my-rails-multi-select
  def filter_blank_multi_selects(values)
    values.reduce({}) { |filtered_params, (key, value)|
      filtered_value = value.is_a?(Array) ? value.reject(&:blank?) : value
      filtered_params.merge(key => filtered_value)
    }
  end

  def services
    AaibReportServiceRegistry.new
  end
end
