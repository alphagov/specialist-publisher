require "specialist_publisher_wiring"
require "forwardable"

class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods
  extend Forwardable

  before_filter :require_signin_permission!

  protect_from_forgery with: :exception

  def finder_schema
    SpecialistPublisherWiring.get(:"#{document_type}_finder_schema")
  end
  helper_method :finder_schema

  def url_maker
    SpecialistPublisherWiring.get(:url_maker)
  end
  def_delegators :url_maker, :published_specialist_document_path
  helper_method :published_specialist_document_path

  def services
    SpecialistPublisherWiring.get(:services)
  end

  def user_can_edit_cma_cases?
    current_organisation_slug == "competition-and-markets-authority"
  end
  helper_method :user_can_edit_cma_cases?

  def user_can_edit_aaib_reports?
    current_organisation_slug == "air-accidents-investigation-branch"
  end
  helper_method :user_can_edit_aaib_reports?

  def current_organisation_slug
    current_user.organisation_slug
  end
end
