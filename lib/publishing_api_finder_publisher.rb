require "gds_api/publishing_api"
require_relative "../app/presenters/finder_content_item_presenter"
require_relative "../app/presenters/finder_signup_content_item_presenter"

class PublishingApiFinderPublisher
  def initialize(metadata, schemae)
    @metadata = metadata
    @schemae = schemae
  end

  def call
    metadata.zip(schemae).map { |metadata, schema|
      export_finder(metadata, schema)
      export_signup(metadata) if metadata.has_key?("signup_content_id")
    }
  end

private
  attr_reader :schemae, :metadata

  def export_finder(metadata, schema)
    finder = FinderContentItemPresenter.new(
      metadata[:file],
      schema[:file],
      metadata[:timestamp],
    )

    attrs = finder.exportable_attributes

    if metadata.has_key?("signup_content_id")
      attrs["links"].merge!({ "email_alert_signup" => [metadata["signup_content_id"]] })
    end
    publishing_api.put_content_item(attrs["base_path"], attrs)
  end

  def export_signup(metadata)
    finder_signup = FinderSignupContentItemPresenter.new(
      metadata[:file],
      metadata[:timestamp],
    )

    attrs = finder_signup.exportable_attributes

    publishing_api.put_content_item(attrs["base_path"], attrs)
  end

  def publishing_api
    @publishing_api ||= GdsApi::PublishingApi.new(Plek.new.find("publishing-api"))
  end
end
