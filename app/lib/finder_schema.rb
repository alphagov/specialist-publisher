require 'multi_json'

class FinderSchema
  def initialize(schema_path)
    @schema_path = schema_path
  end

  def facets
    schema.fetch("facets", []).map do |facet|
      facet.fetch("key").to_sym
    end
  end

  def options_for(facet_name)
    facet_data_for(facet_name).fetch("allowed_values", []).map do |value|
      [
        value.fetch("label", ""),
        value.fetch("value", "")
      ]
    end
  end

private
  def schema
    @schema ||= MultiJson.load(File.read(@schema_path))
  end

  def facet_data_for(facet_name)
    schema.fetch("facets", []).find do |facet_record|
      facet_record.fetch("key") == facet_name.to_s
    end || {}
  end
end
