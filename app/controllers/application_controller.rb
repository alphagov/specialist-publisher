class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include GDS::SSO::ControllerMethods

  before_filter :require_signin_permission!

  helper_method :current_finder

private

  def document_types
    {
      "cma-cases" => OpenStruct.new(
        document_type: "cma_case",
        title: "CMA Cases",
      ),
    }
  end

  def current_finder
    document_types.fetch(params.fetch(:document_type, nil), nil)
  end

end
