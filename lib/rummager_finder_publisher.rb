require "gds_api/rummager"
require_relative "../app/presenters/finder_rummager_presenter"

class RummagerFinderPublisher
  def initialize(metadatas, logger: Logger.new(STDOUT))
    @metadatas = metadatas
    @logger = logger
  end

  def call
    metadatas.each do |metadata|
      if should_publish_in_this_environment?(metadata)
        export_finder(metadata)
      else
        logger.info("Not publishing #{metadata[:file]["name"]} because it is preview_only")
      end
    end
  end

private

  attr_reader :metadatas, :logger

  def should_publish_in_this_environment?(metadata)
    !preview_only?(metadata) || preview_domain_or_not_production?
  end

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
