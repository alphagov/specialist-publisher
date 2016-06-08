require 'gds_api/publishing_api_v2'
require 'gds_api/rummager'
require 'gds_api/asset_manager'
require 'gds_api/email_alert_api'

module Services
  def self.publishing_api
    @publishing_api ||= GdsApi::PublishingApiV2.new(
      Plek.new.find('publishing-api'),
      bearer_token: ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example',
    )
  end

  def self.rummager
    @rummager ||= GdsApi::Rummager.new(Plek.new.find('search'))
  end

  def self.asset_api
    @asset_api ||= GdsApi::AssetManager.new(
      Plek.current.find('asset-manager'),
      bearer_token: ENV['ASSET_MANAGER_BEARER_TOKEN'] || '12345678'
    )
  end

  def self.email_alert_api
    @email_alert_api ||= GdsApi::EmailAlertApi.new(
      Plek.current.find('email-alert-api'),
      bearer_token: ENV['EMAIL_ALERT_API_BEARER_TOKEN'] || 'example123'
    )
  end
end
