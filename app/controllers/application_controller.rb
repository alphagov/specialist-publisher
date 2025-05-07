class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  layout "legacy_application"

  include GDS::SSO::ControllerMethods
  include Pundit::Authorization

  before_action :authenticate_user!
  before_action :set_authenticated_user_header
  after_action :verify_authorized

  helper_method :current_format
  helper_method :formats_user_can_access

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

private

  def user_not_authorized
    flash[:danger] = "You aren't permitted to access #{current_format.title.pluralize}. Please contact your main GDS contact if you need access."
    redirect_to root_path
  end

  def document_type_slug
    params[:document_type_slug]
  end

  def current_format
    @current_format ||= document_models.detect { |model| model.admin_slug == document_type_slug }
  end

  def formats_user_can_access
    FinderSchema.all.filter do |schema|
      policy(schema).index?
    end
  end

  def document_models
    @document_models ||= FinderSchema.schema_names.map do |schema_name|
      schema_name.singularize.camelize.constantize
    end
  end

  def set_authenticated_user_header
    if current_user && GdsApi::GovukHeaders.headers[:x_govuk_authenticated_user].nil?
      GdsApi::GovukHeaders.set_header(:x_govuk_authenticated_user, current_user.uid)
    end
  end
end
