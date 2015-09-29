require "gds_api/publishing_api"
require_relative "../app/presenters/finder_content_item_presenter"
require_relative "../app/presenters/finder_signup_content_item_presenter"

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
        logger.info("Not publishing #{finder[:metadata]["name"]} because it is pre_production")
      end
    end
  end

private
  attr_reader :finders, :logger

  def publish(finder)
    export_finder(finder)
    export_signup(finder) if finder[:metadata].has_key?("signup_content_id")
  end

  def should_publish_in_this_environment?(finder)
    !pre_production?(finder) || should_publish_pre_production_finders?
  end

  def pre_production?(finder)
    finder[:metadata]["pre_production"] == true
  end

  def should_publish_pre_production_finders?
    SpecialistPublisher::Application.config.publish_pre_production_finders
  end

  def export_finder(finder)
    finder = FinderContentItemPresenter.new(
      finder[:metadata],
      finder[:schema],
      finder[:timestamp],
    )

    attrs = finder.exportable_attributes

    logger.info("publishing '#{attrs["title"]}' finder")

    publishing_api.put_content_item(finder.base_path, attrs)
  end

  def export_signup(finder)
    finder_signup = FinderSignupContentItemPresenter.new(
      finder[:metadata],
      finder[:timestamp],
    )

    attrs = finder_signup.exportable_attributes

    logger.info("publishing '#{attrs["title"]}' finder signup page")

    publishing_api.put_content_item(finder_signup.base_path, attrs)
  end

  def publishing_api
    @publishing_api ||= GdsApi::PublishingApi.new(Plek.new.find("publishing-api"))
  end
end
