require "multi_json"

class FinderSchema

  def self.humanized_facet_name(key, entity, type)
    schema = SpecialistPublisherWiring.get("#{type}_finder_schema".to_sym)
    value = entity.send(key)
    schema.humanized_facet_value(key, value)
  end

  def self.options_for(facet_name, type)
    schema = SpecialistPublisherWiring.get("#{type}_finder_schema".to_sym)
    schema.options_for(facet_name)
  end

  def initialize(schema_path)
    @schema_path = schema_path
  end

  def facets
    schema.fetch("facets", []).map do |facet|
      facet.fetch("key").to_sym
    end
  end

  def options_for(facet_name)
    allowed_values_as_option_tuples(allowed_values_for(facet_name))
  end

  def humanized_facet_name(key, &block)
    facet_data_for(key).fetch("name", &block)
  end

  def humanized_facet_value(facet_key, value, &block)
    if facet_data_for(facet_key).fetch("type", nil) == "text"
      Array(value).map do |v|
        value_label_mapping_for(facet_key, v).fetch("label", &block)
      end
    else
      value_label_mapping_for(facet_key, value).fetch("label", &block)
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

  def allowed_values_for(facet_name)
    facet_data_for(facet_name).fetch("allowed_values", [])
  end

  def allowed_values_as_option_tuples(allowed_values)
    allowed_values.map do |value|
      [
        value.fetch("label", ""),
        value.fetch("value", "")
      ]
    end
  end

  def value_label_mapping_for(facet_key, value)
    allowed_values_for(facet_key).find do |av|
      av.fetch("value") == value.to_s
    end || {}
  end
end
