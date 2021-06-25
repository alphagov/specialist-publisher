require "services"

class PublishingApiFinderPublisher
  def initialize(finders, logger: Logger.new($stdout))
    @finders = finders
    @logger = logger
  end

  def call
    finders.map do |finder|
      if should_publish_in_this_environment?(finder)
        publish(finder)
      else
        logger.info("Not publishing #{finder[:file]['name']} because it is pre_production")
      end
    end
  end

private

  attr_reader :finders, :logger

  def publish(finder)
    export_finder(finder)
    export_signup(finder) if finder[:file].key?("signup_content_id")
  end

  def should_publish_in_this_environment?(finder)
    !pre_production?(finder) || Rails.application.config.publish_pre_production_finders
  end

  def pre_production?(finder)
    finder[:file]["pre_production"] == true
  end

  def export_finder(finder)
    finder_payload = FinderContentItemPresenter.new(
      finder[:file],
      finder[:timestamp],
    )

    links_payload = FinderLinksPresenter.new(
      finder[:file],
    )

    noun = (pre_production?(finder) ? "pre-production finder" : "finder")
    logger.info("Publishing #{noun} '#{finder[:file]['name']}'")

    Services.publishing_api.put_content(finder_payload.content_id, finder_payload.to_json)
    Services.publishing_api.patch_links(finder_payload.content_id, links_payload.to_json)
    Services.publishing_api.publish(finder_payload.content_id)
  end

  def export_signup(finder)
    signup_payload = FinderSignupContentItemPresenter.new(
      finder[:file],
      finder[:timestamp],
    )

    links_payload = FinderSignupLinksPresenter.new(
      finder[:file],
    )

    logger.info("Publishing '#{finder[:file]['name']}' finder signup page")

    Services.publishing_api.put_content(signup_payload.content_id, signup_payload.to_json)
    Services.publishing_api.patch_links(signup_payload.content_id, links_payload.to_json)
    Services.publishing_api.publish(signup_payload.content_id)
  end
end
