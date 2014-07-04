require "specialist_publisher_wiring"
require "forwardable"
require "permission_checker"

class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods
  extend Forwardable

  before_filter :require_signin_permission!

  protect_from_forgery with: :exception

  def url_maker
    SpecialistPublisherWiring.get(:url_maker)
  end
  def_delegators :url_maker, :published_specialist_document_path
  helper_method :published_specialist_document_path

  def services
    SpecialistPublisherWiring.get(:services)
  end

  def aaib_report_attachment_services
    SpecialistPublisherWiring.get(:aaib_report_attachment_services)
  end

  def user_can_edit_cma_cases?
    current_user_can_edit?("cma_case")
  end
  helper_method :user_can_edit_cma_cases?

  def user_can_edit_aaib_reports?
    current_user_can_edit?("aaib_report")
  end
  helper_method :user_can_edit_aaib_reports?

  def current_user_can_edit?(format)
    permission_checker.can_edit?(format)
  end

  def current_organisation_slug
    current_user.organisation_slug
  end

  def permission_checker
    @permission_checker ||= PermissionChecker.new(current_user)
  end
end
