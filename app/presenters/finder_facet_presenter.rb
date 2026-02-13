class FinderFacetPresenter
  def initialize(facets)
    @facets = facets
  end

  def to_json(*_args)
    facets_without_specialist_publisher_properties(@facets).map do |facet|
      facet["type"] == "nested" ? hash_with_parent_references(facet) : facet
    end
  end

private

  def facets_without_specialist_publisher_properties(facets)
    facets.reject { |facet| facet["specialist_publisher_properties"]&.fetch("omit_from_finder_content_item", false) }
          .map do |facet|
            facet.delete("specialist_publisher_properties")
            facet
    end
  end

  def hash_with_parent_references(facet_hash)
    facet_hash["allowed_values"].each do |allowed_value|
      allowed_value["sub_facets"]&.each do |sub_facet|
        sub_facet["main_facet_label"] = allowed_value["label"]
        sub_facet["main_facet_value"] = allowed_value["value"]
      end
    end
    facet_hash
  end
end
