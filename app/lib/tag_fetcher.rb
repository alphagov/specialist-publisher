require "gds_api/content_api"

class TagFetcher

  def initialize(manual)
    @manual = manual
  end

  def tags
    if artefact
      artefact.tags
    else
      []
    end
  end

private

  attr_reader :manual

  def artefact
    content_api.artefact(manual.slug)
  end

  def content_api
    @content_api ||= GdsApi::ContentApi.new(Plek.new.find("contentapi"))
  end

end
