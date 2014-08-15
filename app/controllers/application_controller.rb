require "specialist_publisher_wiring"
require "forwardable"
require "permission_checker"
require "url_maker"

class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods
  extend Forwardable

  before_filter :require_signin_permission!

  protect_from_forgery with: :exception

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

  def current_organisation_slug
    current_user.organisation_slug
  end

  def permission_checker
    @permission_checker ||= PermissionChecker.new(current_user)
  end
end
