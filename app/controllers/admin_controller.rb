class AdminController < ApplicationController
  layout "design_system"

  before_action :check_authorisation, if: :document_type_slug

  def edit; end

  def show
    # @proposed_schema = params.permit(
    #   :content_id,
    #   :base_path,
    #   :format_name,
    #   :name,
    #   :description,
    #   :filter,
    #   :show_summaries,
    #   :organisations,
    #   :taxons,
    #   :document_noun,
    #   :document_title,
    #   :facets,
    # )
    @proposed_schema = params.except(:authenticity_token).to_json
  end

private

  def check_authorisation
    if current_format
      authorize current_format
    else
      flash[:danger] = "That format doesn't exist. If you feel you've reached this in error, please contact your main GDS contact."
      redirect_to root_path
    end
  end
end
