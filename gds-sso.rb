GDS::SSO.config do |config|
  config.user_model   = "User"
  config.oauth_id     = ENV["SPECIALIST_PUBLISHER_OAUTH_ID"] || "not used"
  config.oauth_secret = ENV["SPECIALIST_PUBLISHER_OAUTH_SECRET"] || "not used"
  config.oauth_root_url = Plek.current.find("signon")
end
