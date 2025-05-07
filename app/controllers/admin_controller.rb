class AdminController < ApplicationController
  layout "design_system"

  before_action :check_authorisation

  def zendesk
    GdsApi.support_api.raise_support_ticket(support_payload)
    redirect_to finder_path(current_format.admin_slug), notice: "Your changes have been submitted and Zendesk ticket created."
  rescue GdsApi::HTTPErrorResponse
    flash[:danger] = "There was an error submitting your request. Please try again."
    redirect_back(fallback_location: root_path)
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
      description: "Developer - raise a PR replacing this schema with the schema below: " \
        "https://github.com/alphagov/specialist-publisher/edit/main/lib/documents/schemas/#{current_format.document_type.pluralize}.json" \
        "\r\n---\r\n" \
        "```\r\n#{params[:proposed_schema]}\r\n```" \
        "\r\n---\r\n" \
        "Editorial remarks:" \
        "\r\n#{params[:editorial_remark]}",
      requester: {
        name: current_user.name,
        email: current_user.email,
      },
    }
  end
end
