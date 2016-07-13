class User
  include Mongoid::Document
  include GDS::SSO::User

  def self.collection_name
    "specialist_publisher_users"
  end

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
    permissions.include?('gds_editor')
  end

  def organisation_content_id
    organisation_content_id = super

    if organisation_content_id.present?
      organisation_content_id
    else
      {
        "rail-accident-investigation-branch" => "013872d8-8bbb-4e80-9b79-45c7c5cf9177",
      }[organisation_slug]
    end
  end
end
