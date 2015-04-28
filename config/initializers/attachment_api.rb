# This file is overwritten on deployment. In order to authenticate in dev
# environment with asset-manager any random string is required as bearer_token
require "gds_api/asset_manager"
require "plek"

Attachable.asset_api_client = GdsApi::AssetManager.new(
  Plek.current.find("asset-manager"),
  bearer_token: "1234567890",
)
