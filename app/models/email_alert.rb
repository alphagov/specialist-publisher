class EmailAlert
  include ActiveModel::Model

  attr_accessor :enabled, :list_title_prefix, :link, :content_id, :filter

  def self.from_finder_schema(schema)
    email_alert = new
    email_alert.enabled = if schema.signup_content_id.present? && schema.email_filter_by.present?
                            :filtered_content
                          elsif schema.signup_link.present?
                            :external
                          elsif schema.signup_content_id.present?
                            :all_content
                          else
                            :no
                          end
    email_alert.content_id = schema.signup_content_id
    email_alert.list_title_prefix = schema.subscription_list_title_prefix
    email_alert.filter = schema.email_filter_by
    email_alert.link = schema.signup_link
    email_alert
  end

  def self.from_finder_admin_form_params(params)
    email_alert = new
    email_alert.enabled = params["email_alerts_enabled"].to_sym
    if email_alert.enabled == :all_content
      email_alert.content_id = params["all_content_signup_id"]
      email_alert.list_title_prefix = params["all_content_list_title_prefix"]
    end
    if email_alert.enabled == :filtered_content
      email_alert.content_id = params["filtered_content_signup_id"]
      email_alert.list_title_prefix = params["filtered_content_list_title_prefix"]
      email_alert.filter = params["email_filter_by"]
    end
    if email_alert.enabled == :external
      email_alert.link = params["signup_link"]
    end
    email_alert
  end

  def to_finder_schema_attributes
    {
      signup_content_id: content_id,
      subscription_list_title_prefix: list_title_prefix,
      email_filter_by: filter,
      signup_link: link,
    }
  end
end
