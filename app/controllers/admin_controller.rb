class AdminController < ApplicationController
  layout "design_system"

  before_action :check_authorisation, if: :document_type_slug

  def summary; end

  def edit_facets; end

  def edit_metadata; end

  def confirm_facets
    # TODO should 'require' :facets
    @params = params.permit(
      :facets => [
        :name,
        :short_name,
        :type,
        :allowed_values,
        :filterable,
        :display_as_result_metadata,
        :TODO, #
        :preposition,
     ]
    )
    @params["facets"] = @params["facets"].values
    @params["facets"].each do |facet|
      if facet["allowed_values"]
        # TODO
        # facet["allowed_values"] = [ { key: "foo", name: "Foo" } ]
        facet["allowed_values"] = facet["allowed_values"].split(",").map { |str| { key: str, name: str } }
      end
    end

    @proposed_schema = FinderSchema.new(@current_format.finder_schema.attributes)
    @proposed_schema.update(@params)

    render :confirm_facets
  end

  def confirm_metadata
    @params = params.permit(
      :name,
      :base_path,
      :description,
      :summary,
      :show_summaries,
      :document_noun,
      organisations: [],
      related: [],
    )

    email_alert = EmailAlert.from_finder_admin_form_params(email_alert_params)
    @params.merge!(email_alert.to_finder_schema_attributes)

    @proposed_schema = FinderSchema.new(@current_format.finder_schema.attributes)
    @proposed_schema.update(@params.to_unsafe_h)

    if params[:include_related] != "true"
      @proposed_schema.related = nil
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
      description: "Developer - raise a PR replacing this schema with the schema below: " \
        "https://github.com/alphagov/specialist-publisher/edit/main/lib/documents/schemas/#{current_format.document_type.pluralize}.json" \
        "\r\n---\r\n" \
        "```\r\n#{params[:proposed_schema]}\r\n```",
      requester: {
        name: current_user.name,
        email: current_user.email,
      },
    }
  end

  def email_alert_params
    params.permit(
      :email_alert_type,
      :all_content_signup_id,
      :all_content_list_title_prefix,
      :filtered_content_signup_id,
      :filtered_content_list_title_prefix,
      :email_filter_by,
      :signup_link,
    )
  end
end
