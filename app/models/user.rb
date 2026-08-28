class User < ApplicationRecord
  include GDS::SSO::User

  serialize :permissions, type: Array, coder: YAML

  def gds_editor?
    permissions.include?("gds_editor")
  end
end
