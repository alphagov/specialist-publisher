require "services"

class PublishingApiFinderPublisher
  def initialize(finders, logger: Logger.new($stdout))
    @finders = finders
    @logger = logger
  end

  def call
    finders.map do |finder|
      export_finder(finder)
      export_signup(finder) if finder[:file].key?("signup_content_id")
    end
  end

private

  attr_reader :finders, :logger

  def should_deploy_to_live?(finder)
    finder[:file]["target_stack"] == "live"
  end

  def export_finder(finder)
    finder_payload = FinderContentItemPresenter.new(
      finder[:file],
      finder[:timestamp],
    )

    links_payload = FinderLinksPresenter.new(
      finder[:file],
    )

    target_stack = finder[:file]["target_stack"]
    logger.info("Publishing '#{finder[:file]['name']}' to #{target_stack} stack")

    update_draft(finder_payload)
    publish(finder_payload, links_payload) if should_deploy_to_live?(finder)
  end

  def export_signup(finder)
    signup_payload = FinderSignupContentItemPresenter.new(
      finder[:file],
      finder[:timestamp],
    )

    links_payload = FinderSignupLinksPresenter.new(
      finder[:file],
    )

    target_stack = finder[:file]["target_stack"]
    logger.info("Publishing '#{finder[:file]['name']}' finder signup page to #{target_stack} stack")

    update_draft(signup_payload)
    publish(signup_payload, links_payload) if should_deploy_to_live?(finder)
  end

  def update_draft(payload)
    Services.publishing_api.put_content(payload.content_id, payload.to_json)
  end

  def publish(payload, links_payload)
    Services.publishing_api.patch_links(payload.content_id, links_payload.to_json)
    Services.publishing_api.publish(payload.content_id)
  end
end
