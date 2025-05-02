class FindersController < ApplicationController
  layout "design_system"
  def index
    if current_user.preview_design_system?
      authorize current_user, :index?, policy_class: FinderAdministrationPolicy
    end
  end
end
