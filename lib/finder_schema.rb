class FinderSchema

  attr_reader :organisations

  def initialize(schema_type)
    @schema ||= load_schema_for(schema_type)
    @organisations = schema.fetch("organisations", [])
  end

  def facets
    schema.fetch("facets", []).map do |facet|
      facet.fetch("key").to_sym
    end
  end

  def options_for(facet_name)
    allowed_values_as_option_tuples(allowed_values_for(facet_name))
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

  def humanized_facet_name(key, &block)
    facet_data_for(key).fetch("name", &block)
  end

private

  attr_reader :schema

  def load_schema_for(type)
    JSON.load(File.read(Rails.root.join("lib/documents/schemas/#{type}.json")))
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
    allowed_values_for(facet_key).find do |allowed_value|
      allowed_value.fetch("value") == value.to_s
    end || {}
  end
end
