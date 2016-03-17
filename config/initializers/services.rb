require 'gds_api/publishing_api_v2'
require 'gds_api/rummager'
require 'gds_api/asset_manager'

module SpecialistPublisher

  def self.register_service(name, service)
    @services ||= {}

    @services[name] = service
  end

  def self.services(name)
    @services[name] or raise ServiceNotRegisteredException.new(name)
  end

  class ServiceNotRegisteredException < Exception; end

end

SpecialistPublisher.register_service(:publishing_api, GdsApi::PublishingApiV2.new(
  Plek.new.find('publishing-api'),
  bearer_token: ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example'
))
SpecialistPublisher.register_service(:rummager, GdsApi::Rummager.new(Plek.new.find('search')))

SpecialistPublisher.register_service(:asset_api, GdsApi::AssetManager.new(
  Plek.current.find('asset-manager'),
  bearer_token: ENV['ASSET_MANAGER_BEARER_TOKEN'] || '12345678'
))

