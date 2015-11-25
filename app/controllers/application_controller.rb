class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include GDS::SSO::ControllerMethods

  before_filter :require_signin_permission!

  helper_method :current_format

private

  def current_format
    document_types.fetch(params.fetch(:document_type, nil), nil)
  end

  def document_types
    # For each format that follows the standard naming convention, this
    # method takes the title and name of the model class of eacg format
    # like this:
    #
    # data = {
    #   "GDS Report" => GdsReport
    # }
    #
    # which will become this:
    #
    # {
    #   "gds-reports" => {
    #     klass: GdsReports
    #     document_type: "gds-reports",
    #     format_name: "gds_report",
    #     title: "GDS Report"
    #   }
    # }

    data = {
      "CMA Case" => CmaCase
    }

    data.map do |k, v|
      {
        k.downcase.parameterize.pluralize => OpenStruct.new(
          klass: v,
          document_type: k.downcase.parameterize.pluralize,
          format_name: k.downcase.parameterize.underscore,
          title: k,
        )
      }
    end.reduce({}, :merge)
  end

end
