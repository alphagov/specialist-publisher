class User
  include Mongoid::Document
  include GDS::SSO::User

  store_in collection: :specialist_publisher_users

  field :uid, type: String
  field :email, type: String
  field :version, type: Integer
  field :name, type: String
  field :permissions, type: Array
  field :remotely_signed_out, type: Boolean, default: false
  field :organisation_slug, type: String
  field :organisation_content_id, type: String
  field :disabled, type: Boolean, default: false

  def gds_editor?
    permissions.include?("gds_editor")
  end
end
