class TempController < ApplicationController
  layout "design_system"

  before_action :check_authorisation

  def index; end

private

  def check_authorisation
    authorize AaibReport # ignore this
  end
end
