class TempController < ApplicationController
  layout "design_system"

  before_action :check_authorisation

  def index; end

private

  def check_authorisation
    # A `Pundit::AuthorizationNotPerformedError` exception is raised
    # unless we call the `authorize` model against an existing model.
    # This will likely be swapped out for `authorize current_format` when
    # we remove the temporary page and add the admin form pages.
    authorize AaibReport
  end
end
