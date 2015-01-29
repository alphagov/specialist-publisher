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
      if metadata[:file].has_key?("content_id")
        export_finder(metadata, schema)
        export_signup(metadata) if metadata[:file].has_key?("signup_content_id")
      else
        puts "didn't publish #{metadata[:file]["name"]} because it doesn't have a content_id"
      end
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

    puts "publishing '#{attrs["title"]}' finder"

    publishing_api.put_content_item(attrs["base_path"], attrs)
  end

  def export_signup(metadata)
    finder_signup = FinderSignupContentItemPresenter.new(
      metadata[:file],
      metadata[:timestamp],
    )

    attrs = finder_signup.exportable_attributes

    puts "publishing '#{attrs["title"]}' finder signup page"

    publishing_api.put_content_item(attrs["base_path"], attrs)
  end

  def publishing_api
    @publishing_api ||= GdsApi::PublishingApi.new(Plek.new.find("publishing-api"))
  end
end
