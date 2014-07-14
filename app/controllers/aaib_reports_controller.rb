require "aaib_report_service_registry"

class AaibReportsController < AbstractDocumentsController
private
  def document_params
    params.fetch("aaib_report", {})
  end

  def form_object_for(document)
    AaibReportForm.new(document)
  end

  def authorize_user
    unless user_can_edit_aaib_reports?
      redirect_to(
        manuals_path,
        flash: { error: "You don't have permission to do that." },
      )
    end
  end

  def services
    AaibReportServiceRegistry.new
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

  def index_path
    aaib_reports_path
  end

  def show_path(document)
    aaib_report_path(document)
  end
end
