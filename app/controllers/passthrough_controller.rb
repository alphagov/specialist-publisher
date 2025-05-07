class PassthroughController < ApplicationController
  layout "design_system"
  before_action :skip_authorization
  def index
    if current_user.preview_design_system?
      redirect_to finders_path
    elsif first_permitted_format
      redirect_to documents_path(document_type_slug: first_permitted_format.admin_slug)
    else
      redirect_to error_path
    end
  end

  def error; end

private

  def first_permitted_format
    @first_permitted_format ||= document_models.sort_by(&:name).find do |document_class|
      DocumentPolicy.new(current_user, document_class).index?
    end
  end
end
