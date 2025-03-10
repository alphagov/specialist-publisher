class FinderFacetPresenter
  def initialize(facets)
    @facets = facets
  end

  def to_json(*_args)
    facets_without_specialist_publisher_properties(@facets).map { |facet|
      facet["nested_facet"] ? [main_facet_hash_without_sub_facets(facet), sub_facet_hash(facet)] : facet
    }.flatten
  end

private

  def facets_without_specialist_publisher_properties(facets)
    facets.reject { |facet| facet["specialist_publisher_properties"]&.fetch("omit_from_finder_content_item", false) }
          .map do |facet|
      facet.delete("specialist_publisher_properties")
      facet
    end
  end

  def main_facet_hash_without_sub_facets(facet_hash)
    hash_dup = facet_hash.dup
    hash_dup["allowed_values"] = hash_dup["allowed_values"].map { |v| v.except("sub_facets") }

    hash_dup
  end

  def sub_facet_hash(facet_hash)
    facet_hash.merge(
      "allowed_values" => sub_facet_allowed_values(facet_hash),
      "key" => facet_hash["sub_facet_key"],
      "name" => facet_hash["sub_facet_name"],
      "sub_facet_key" => nil,
      "sub_facet_name" => nil,
      "main_facet_key" => facet_hash["key"],
      "short_name" => facet_hash["sub_facet_name"],
      "preposition" => facet_hash["sub_facet_name"],
    ).compact
  end

  def sub_facet_allowed_values(facet_hash)
    facet_hash["allowed_values"].each_with_object([]) do |allowed_value, sub_facets|
      main_label = allowed_value["label"]
      main_value = allowed_value["value"]

      allowed_value["sub_facets"]&.each do |sub_facet|
        sub_facets << sub_facet.merge("main_facet_label" => main_label, "main_facet_value" => main_value)
      end
    end
  end
end
