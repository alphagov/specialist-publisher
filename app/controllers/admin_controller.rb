class AdminController < ApplicationController
  layout "design_system"

  before_action :check_authorisation, if: :document_type_slug

  def summary; end

  def edit_metadata; end

  def confirm_metadata
    @params = params.permit(
      :name,
      :base_path,
      :description,
      :summary,
      :document_noun,
      organisations: [],
      related: [],
    )

    @params[:organisations].reject!(&:empty?)
    @params[:related].reject!(&:empty?)

    @proposed_schema = @current_format.finder_schema.schema.merge(@params.to_unsafe_h)

    @proposed_schema["signup_copy"] = "You'll get an email each time a #{@params[:document_noun]} is updated or a new #{@params[:document_noun]} is published."

    if params[:include_related] != "true"
      @proposed_schema.delete("related")
    end

    if @proposed_schema["show_summaries"] == "true"
      @proposed_schema["show_summaries"] = true
    else
      @proposed_schema.delete("show_summaries")
    end

    render :confirm_metadata
  end

  def zendesk
    GdsApi.support_api.raise_support_ticket(support_payload)
    redirect_to "/admin/#{current_format.admin_slug}", notice: "Your changes have been submitted and Zendesk ticket created."
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

  def support_payload
    {
      subject: "Specialist Finder Edit Request: #{current_format.title.pluralize}",
      tags: %w[specialist_finder_edit_request],
      priority: "normal",
      description: "```\r\n#{params[:proposed_schema]}\r\n```",
      requester: {
        name: current_user.name,
        email: current_user.email,
      },
    }
  end
end
