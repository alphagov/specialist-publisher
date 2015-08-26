require "gds_api/publishing_api"
require_relative "../app/presenters/finder_content_item_presenter"
require_relative "../app/presenters/finder_signup_content_item_presenter"

class PublishingApiFinderPublisher
  def initialize(metadata, schemae, log = true)
    @metadata = metadata
    @schemae = schemae
    @log = log
  end

  def call
    metadata.zip(schemae).map do |metadata, schema|
      if metadata[:file].has_key?("content_id") && !preview_only?(metadata)
        publish metadata, schema
      elsif preview_only?(metadata)
        if preview_domain_or_not_production?
          publish metadata, schema
        else
          puts "didn't publish #{metadata[:file]["name"]} because it is preview_only" if @log
        end
      else
        puts "didn't publish #{metadata[:file]["name"]} because it doesn't have a content_id" if @log
      end
    end
  end

private
  attr_reader :schemae, :metadata

  def publish metadata, schema
    export_finder(metadata, schema)
    export_signup(metadata) if metadata[:file].has_key?("signup_content_id")
  end

  def preview_only? metadata
    metadata[:file]["preview_only"] == true
  end

  def preview_domain_or_not_production?
    ENV.fetch("GOVUK_APP_DOMAIN", "")[/preview/] || !Rails.env.production?
  end

  def export_finder(metadata, schema)
    finder = FinderContentItemPresenter.new(
      metadata[:file],
      schema[:file],
      metadata[:timestamp],
    )

    attrs = finder.exportable_attributes

    puts "publishing '#{attrs["title"]}' finder" if @log

    publishing_api.put_content_item(finder.base_path, attrs)
  end

  def export_signup(metadata)
    finder_signup = FinderSignupContentItemPresenter.new(
      metadata[:file],
      metadata[:timestamp],
    )

    attrs = finder_signup.exportable_attributes

    puts "publishing '#{attrs["title"]}' finder signup page" if @log

    publishing_api.put_content_item(finder_signup.base_path, attrs)
  end

  def publishing_api
    @publishing_api ||= GdsApi::PublishingApi.new(Plek.new.find("publishing-api"))
  end
end
