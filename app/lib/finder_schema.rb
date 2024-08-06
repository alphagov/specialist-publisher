class FinderSchema
  # Pluralized names of all document types
  def self.schema_names
    Dir.glob(Rails.root.join("lib/documents/schemas/*.json")).map do |f|
      File.basename(f).gsub(".json", "")
    end
  end

  attr_reader :base_path, :organisations, :format, :content_id, :editing_organisations

  def initialize(content_id: nil)
    @schema = load_remote_schema(content_id)
    @base_path = schema.fetch("base_path")
    @organisations = schema.fetch("organisations", [])
    @editing_organisations = schema.fetch("editing_organisations", [])
    @format = schema.fetch("details", {}).fetch("filter", {}).fetch("format")
    @content_id = schema.fetch("content_id")
  end

  def facets
    schema.fetch("details", []).fetch("facets", []).map do |facet|
      facet.fetch("key").to_sym
    end
  end

  def options_for(facet_name_as_symbol)
    facet = schema&.fetch("details")&.fetch("facets")&.find { |facet_record| facet_name_as_symbol == facet_record["key"].to_sym }
    allowed_values = facet.dig("allowed_values") || []
    allowed_values_as_option_tuples(allowed_values)
  end

  def humanized_facet_value(facet_key, value)
    facet = facet_data(facet_key)
    allowed_values = facet.dig("allowed_values") || []
    type = facet.fetch("type")
    if type == "text" && allowed_values.empty?
      value
    elsif %w[hidden text].include?(type)
      Array(value).map do |v|
        value_label_mapping_for(allowed_values, v).fetch("label") { value }
      end
    else
      value_label_mapping_for(allowed_values, value).fetch("label") { value }
    end
  end

  def humanized_facet_name(key)
    facet_data(key)&.fetch("name") || key.to_s.humanize
  end

private

  attr_reader :schema

  def load_remote_schema(content_id)
    DocumentFinder.find(Finder, content_id, "en")
  end

  def facet_data(key)
    schema&.fetch("details")&.fetch("facets")&.find { |facet_record| key == facet_record["key"] }
  end

  def allowed_values_as_option_tuples(allowed_values)
    allowed_values.map do |value|
      [
        value.fetch("label", ""),
        value.fetch("value", ""),
      ]
    end
  end

  def value_label_mapping_for(allowed_values, value)
    allowed_values.find do |allowed_value|
      allowed_value.fetch("value") == value.to_s
    end || {}
  end
end
