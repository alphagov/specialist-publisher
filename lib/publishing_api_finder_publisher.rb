require "gds_api/publishing_api"
require_relative "../app/presenters/finders/finder_content_item_presenter"
require_relative "../app/presenters/finders/finder_links_presenter"
require_relative "../app/presenters/finders/finder_signup_content_item_presenter"
require_relative "../app/presenters/finders/finder_signup_links_presenter"

class PublishingApiFinderPublisher
  def initialize(finders, logger: Logger.new(STDOUT))
    @finders = finders
    @logger = logger
  end

  def call
    finders.map do |finder|
      if should_publish_in_this_environment?(finder)
        publish(finder)
      else
        logger.info("Not publishing #{finder[:file]["title"]} because it is pre_production")
      end
    end
  end

private
  attr_reader :finders, :logger

  def publish(finder)
    export_finder(finder)
    export_signup(finder) if finder[:file].has_key?("signup_content_id")
  end

  def should_publish_in_this_environment?(finder)
    !pre_production?(finder) || should_publish_pre_production_finders?
  end

  def pre_production?(finder)
    finder[:file]["pre_production"] == true
  end

  def should_publish_pre_production_finders?
    SpecialistPublisher::Application.config.publish_pre_production_finders
  end

  def export_finder(finder)
    finder_payload = FinderContentItemPresenter.new(
      finder[:file],
      finder[:timestamp],
    )

    links_payload = FinderLinksPresenter.new(
      finder[:file],
    )

    logger.info("publishing '#{finder[:file]["name"]}' finder")

    publishing_api.put_content(finder_payload.content_id, finder_payload.to_json)
    publishing_api.patch_links(finder_payload.content_id, links_payload.to_json)
    publishing_api.publish(finder_payload.content_id, "major")
  end

  def export_signup(finder)
    signup_payload = FinderSignupContentItemPresenter.new(
      finder[:file],
      finder[:timestamp],
    )

    links_payload = FinderSignupLinksPresenter.new(
      finder[:file],
    )

    logger.info("publishing '#{finder[:file]["name"]}' finder signup page")

    publishing_api.put_content(signup_payload.content_id, signup_payload.to_json)
    publishing_api.patch_links(signup_payload.content_id, links_payload.to_json)
    publishing_api.publish(signup_payload.content_id, "major")
  end

  def publishing_api
    SpecialistPublisher.services(:publishing_api)
  end
end
