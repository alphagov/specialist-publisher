class PassthroughController < ApplicationController
  layout "design_system"
  before_action :skip_authorization

  def index
    redirect_to finders_path
  end
end
