require "specialist_publisher_wiring"
require "forwardable"
require "permission_checker"
require "url_maker"

class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods
  extend Forwardable

  before_filter :require_signin_permission!

  protect_from_forgery with: :exception

  def current_finder
    finders.fetch(request.path.split("/")[1], nil)
  end
  helper_method :current_finder

  def finders
    {
      "aaib-reports" => {
        document_type: "aaib_report",
        title: "AAIB Reports",
      },
      "cma-cases" => {
        document_type: "cma_case",
        title: "CMA Cases",
      },
      "international-development-funds" => {
        document_type: "international_development_fund",
        title: "International Development Funds",
      },
      "drug-safety-updates" => {
        document_type: "drug_safety_update",
        title: "Drug Safety Update",
      },
      "medical-safety-alerts" => {
        document_type: "medical_safety_alert" ,
        title: "Medical Safety Alerts",
      },
      "maib-reports" => {
        document_type: "maib_report",
        title: "MAIB Reports",
      },
      "raib-reports" => {
        document_type: "raib_report",
        title: "RAIB Reports",
      },
    }
  end
  helper_method :finders

  def url_maker
    UrlMaker.new
  end
  def_delegators :url_maker, :published_specialist_document_path
  helper_method :published_specialist_document_path

  def current_user_can_edit?(format)
    permission_checker.can_edit?(format)
  end
  helper_method :current_user_can_edit?

  def current_user_can_publish?(format)
    permission_checker.can_publish?(format)
  end
  helper_method :current_user_can_publish?

  def current_user_can_withdraw?(format)
    permission_checker.can_withdraw?(format)
  end
  helper_method :current_user_can_withdraw?

  def current_user_is_gds_editor?
    permission_checker.is_gds_editor?
  end
  helper_method :current_user_is_gds_editor?

  def current_organisation_slug
    current_user.organisation_slug
  end

  def permission_checker
    @permission_checker ||= PermissionChecker.new(current_user)
  end
end
