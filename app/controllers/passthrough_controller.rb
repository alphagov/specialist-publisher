class PassthroughController < ApplicationController
  before_action :skip_authorization

  def index
    redirect_to finders_path
  end
end
