class PassthroughController < ApplicationController
  after_action :skip_authorization

  def index
    current_organisation = document_models.find { |model| model.organisations.include? current_user.organisation_content_id }

    if current_user.gds_editor?
      redirect_to "/aaib-reports"
    elsif current_organisation
      redirect_to "/" + current_organisation.slug
    else
      redirect_to error_path
    end
  end

  def error
  end
end
