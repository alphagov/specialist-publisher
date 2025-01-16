class EmailAlert
  include ActiveModel::Model

  attr_accessor :type, :list_title_prefix, :link, :content_id, :email_filter_options, :email_filter_by_candidates

  def to_finder_schema_attributes
    {
      signup_content_id: content_id.presence,
      subscription_list_title_prefix: list_title_prefix,
      email_filter_options:,
      signup_link: link.presence,
    }
  end

  def filter
    email_filter_options&.fetch("email_filter_by", nil)
  end

  class << self
    def from_finder_schema(schema)
      email_alert = new
      email_alert.type = email_alert_type(schema)
      email_alert.content_id = schema.signup_content_id
      email_alert.list_title_prefix = schema.subscription_list_title_prefix
      email_alert.email_filter_options = schema.email_filter_options
      email_alert.link = schema.signup_link
      email_alert.email_filter_by_candidates = %w[all_selected_facets] + schema.facets.map { |facet| facet["key"] }
      email_alert
    end

    def from_finder_admin_form_params(params)
      email_alert = new
      email_alert.type = params["email_alert_type"].to_sym
      email_alert.assign_attributes(email_alert_params_by_type(params, email_alert.type))
      email_alert
    end

  private

    def email_alert_type(schema)
      return :filtered_content if schema.signup_content_id.present? && schema.email_filter_options.present?
      return :external if schema.signup_link.present?
      return :all_content if schema.signup_content_id.present?

      :no
    end

    def email_alert_params_by_type(params, type)
      {
        all_content: all_content_params(params),
        filtered_content: filtered_content_params(params),
        external: external_params(params),
      }[type] || {}
    end

    def all_content_params(params)
      {
        content_id: params["all_content_signup_id"],
        list_title_prefix: params["all_content_list_title_prefix"],
        email_filter_options: email_filter_options_for_all_content(params),
      }
    end

    def filtered_content_params(params)
      {
        content_id: params["filtered_content_signup_id"],
        list_title_prefix: params["filtered_content_list_title_prefix"],
        email_filter_options: email_filter_options_for_filtered_content(params),
      }
    end

    def email_filter_options_for_all_content(params)
      return if params["all_content_email_filter_options"].nil?

      email_filter_options = JSON.parse(params["all_content_email_filter_options"])
      email_filter_options.delete("email_filter_by")
      email_filter_options.delete("pre_checked_email_alert_checkboxes")
      email_filter_options
    end

    def email_filter_options_for_filtered_content(params)
      email_filter_options = JSON.parse(params["filtered_content_email_filter_options"] || "{}")
      email_filter_options.merge("email_filter_by" => params["email_filter_by"])
    end

    def external_params(params)
      { link: params["signup_link"] }
    end
  end
end
