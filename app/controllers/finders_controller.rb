class FindersController < ApplicationController
  layout "design_system"
  def index
    skip_authorization
  end

  def new
    authorize FinderSchema, :can_request_new_finder?
    @proposed_schema = FinderSchema.new
    @proposed_schema.facets = []
  end

  def create
    authorize FinderSchema, :can_request_new_finder?
    @proposed_schema = FinderSchema.new
    @proposed_schema.facets = []
    @proposed_schema.content_id = SecureRandom.uuid
    overwrite_with_facets_params(@proposed_schema)
    overwrite_with_metadata_params(@proposed_schema)

    render :new
  end

  def show
    authorize current_format
  end

  def edit_metadata
    authorize current_format
  end

  def update_metadata
    authorize current_format
    @proposed_schema = FinderSchema.new(current_format.finder_schema.attributes)
    overwrite_with_metadata_params(@proposed_schema)
  end

  def edit_facets
    authorize current_format
  end

  def update_facets
    authorize current_format
    @proposed_schema = FinderSchema.new(current_format.finder_schema.attributes)
    overwrite_with_facets_params(@proposed_schema)
  end

  def zendesk
    authorize current_format
    GdsApi.support_api.raise_support_ticket(support_payload)
    redirect_to finder_path(current_format.admin_slug), notice: "Your changes have been submitted and Zendesk ticket created."
  rescue GdsApi::HTTPErrorResponse
    flash[:danger] = "There was an error submitting your request. Please try again."
    redirect_back(fallback_location: root_path)
  end

private

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

  def metadata_params
    params.permit(
      :name,
      :base_path,
      :description,
      :summary,
      :show_summaries,
      :show_metadata_block,
      :show_table_of_contents,
      :document_title,
      :document_noun,
      organisations: [],
      related: [],
    )
  end

  def email_alert_params
    params.permit(
      :email_alert_type,
      :all_content_signup_id,
      :all_content_list_title_prefix,
      :all_content_email_filter_options,
      :filtered_content_signup_id,
      :filtered_content_list_title_prefix,
      :filtered_content_email_filter_options,
      :email_filter_by,
      :signup_link,
    )
  end

  def facets_params
    params.permit(
      facets: [
        :key,
        :name,
        :sub_facet,
        :short_name,
        :show_option_select_filter,
        :type,
        :preposition,
        :display_as_result_metadata,
        :filterable,
        :allowed_values,
        :_destroy,
        { validations: [] },
      ],
    )
  end

  def overwrite_with_metadata_params(proposed_schema)
    email_alert = EmailAlert.from_finder_admin_form_params(email_alert_params)
    params_to_overwrite = metadata_params.merge!(email_alert.to_finder_schema_attributes)
    proposed_schema.update(params_to_overwrite.to_unsafe_h)

    if params[:document_title] && proposed_schema.filter.blank?
      proposed_schema.filter = { "format" => params[:document_title].parameterize(separator: "_") }
    end

    if params[:include_related] != "true"
      proposed_schema.related = nil
    end
  end

  def overwrite_with_facets_params(proposed_schema)
    params_to_overwrite = facets_params
    submitted_facets = params_to_overwrite["facets"]&.values || [] # `nil` if "new finder" form is submitted without any facets
    params_to_overwrite["facets"] = submitted_facets.map { |facet_params|
      next if facet_params["_destroy"] == "1"

      Facet.from_finder_admin_form_params(facet_params)
           .to_finder_schema_attributes
    }.compact
    proposed_schema.update(params_to_overwrite)
  end
end
