require "gds_api/rummager"
require_relative "../app/presenters/finder_rummager_presenter"

class RummagerFinderPublisher
  def initialize(metadatas)
    @metadatas = metadatas
  end

  def call
    @metadatas.each do |metadata|
      if metadata[:file].has_key?("content_id")
        export_finder(metadata)
      else
        # Even though rummager doesn't use the content_id we only want to push
        # to rummager if this is live in content-store, so this needs to
        # replicate the logic in PublishingApiFinderPublisher.
        puts "didn't publish #{metadata[:file]["name"]} because it doesn't have a content_id"
      end
    end
  end

  private

  def export_finder(metadata)
    presenter = FinderRummagerPresenter.new(metadata[:file], metadata[:timestamp])
    rummager.add_document(presenter.type, presenter.id, presenter.attributes)
  end

  def rummager
    @rummager ||= GdsApi::Rummager.new(Plek.new.find("rummager"))
  end
end
