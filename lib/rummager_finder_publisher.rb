require "gds_api/rummager"
require_relative "../app/presenters/finder_rummager_presenter"

class RummagerFinderPublisher
  def initialize(metadatas, logger: Logger.new(STDOUT))
    @metadatas = metadatas
    @logger = logger
  end

  def call
    metadatas.each do |metadata|
      if metadata[:file].has_key?("content_id") && !preview_only?(metadata)
        export_finder(metadata)
      elsif preview_only?(metadata)
        if preview_domain_or_not_production?
          export_finder(metadata)
        else
          logger.info("didn't publish #{metadata[:file]["name"]} because it is preview_only")
        end
      else
        # Even though rummager doesn't use the content_id we only want to push
        # to rummager if this is live in content-store, so this needs to
        # replicate the logic in PublishingApiFinderPublisher.
        logger.info("didn't publish #{metadata[:file]["name"]} because it doesn't have a content_id")
      end
    end
  end

private

  attr_reader :metadatas, :logger

  def preview_only?(metadata)
    metadata[:file]["preview_only"] == true
  end

  def preview_domain_or_not_production?
    ENV.fetch("GOVUK_APP_DOMAIN", "")[/preview/] || !Rails.env.production?
  end

  def export_finder(metadata)
    presenter = FinderRummagerPresenter.new(metadata[:file], metadata[:timestamp])
    rummager.add_document(presenter.type, presenter.id, presenter.attributes)
  end

  def rummager
    @rummager ||= GdsApi::Rummager.new(Plek.new.find("rummager"))
  end
end
