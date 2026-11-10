class User < ApplicationRecord
  include GDS::SSO::User

  serialize :permissions, type: Array, coder: YAML

  module Permissions
    SIGNIN = "signin".freeze
  end

  def gds_editor?
    permissions.include?("gds_editor")
  end
end
