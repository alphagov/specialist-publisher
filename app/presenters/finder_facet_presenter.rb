class FinderFacetPresenter
  def initialize(facets)
    @facets = facets
  end

  def to_json(*_args)
    facets_without_specialist_publisher_properties(@facets)
  end

private

  def facets_without_specialist_publisher_properties(facets)
    facets.reject { |facet| facet["specialist_publisher_properties"]&.fetch("omit_from_finder_content_item", false) }
          .map do |facet|
      facet.delete("specialist_publisher_properties")
      facet
    end
  end
end
