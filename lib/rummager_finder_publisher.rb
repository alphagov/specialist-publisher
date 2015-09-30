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
        logger.info("Not publishing #{metadata[:file]["name"]} because it is pre_production")
      end
    end
  end

private

  attr_reader :metadatas, :logger

  def should_publish_in_this_environment?(metadata)
    !pre_production?(metadata) || should_publish_pre_production_finders?
  end

  def pre_production?(metadata)
    metadata[:file]["pre_production"] == true
  end

  def should_publish_pre_production_finders?
    SpecialistPublisher::Application.config.publish_pre_production_finders
  end

  def export_finder(metadata)
    presenter = FinderRummagerPresenter.new(metadata[:file], metadata[:timestamp])
    rummager.add_document(presenter.type, presenter.id, presenter.attributes)
  end

  def rummager
    @rummager ||= GdsApi::Rummager.new(Plek.new.find("rummager"))
  end
end
