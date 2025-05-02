class FindersController < ApplicationController
  layout "design_system"
  def index
    if current_user.preview_design_system?
      authorize current_user, :index?, policy_class: FinderAdministrationPolicy
    end
  end

  def new
    authorize current_user, :can_request_new_finder?, policy_class: FinderAdministrationPolicy
    @proposed_schema = FinderSchema.new
    @proposed_schema.facets = []
  end

  def create
    authorize current_user, :can_request_new_finder?, policy_class: FinderAdministrationPolicy
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
