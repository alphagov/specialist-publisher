require "gds_api/asset_manager"
require "plek"

Attachable.asset_api_client = GdsApi::AssetManager.new(Plek.current.find("asset-manager"))
