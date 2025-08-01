class Facet
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :key
  attribute :name
  attribute :short_name
  attribute :type
  attribute :preposition
  attribute :display_as_result_metadata, :boolean
  attribute :filterable, :boolean
  attribute :allowed_values
  attribute :specialist_publisher_properties
  attribute :show_option_select_filter, :boolean
  attribute :sub_facet_name
  attribute :sub_facet_key

  def to_finder_schema_attributes
    {
      allowed_values:,
      display_as_result_metadata:,
      filterable:,
      key:,
      name:,
      preposition:,
      short_name:,
      show_option_select_filter:,
      specialist_publisher_properties:,
      sub_facet_key:,
      sub_facet_name:,
      type:,
    }.compact
  end

  class << self
    def from_finder_admin_form_params(params)
      facet = new
      facet.key = params["key"] || str_to_key(params["name"], separator: "_")
      facet.name = params["name"]
      facet.short_name = nil_if_blank(params["short_name"])
      facet.type = facet_type(params["type"])
      facet.preposition = nil_if_blank(params["preposition"])
      facet.display_as_result_metadata = params["display_as_result_metadata"]
      facet.filterable = params["filterable"]
      facet.allowed_values = facet_allowed_values(params["allowed_values"], params["type"])
      facet.specialist_publisher_properties = facet_specialist_publisher_properties(params["type"], params["validations"])
      facet.show_option_select_filter = nil_if_false(params["show_option_select_filter"])
      facet.sub_facet_name = extract_label(params["sub_facet"]) if params["sub_facet"].present?
      facet.sub_facet_key = extract_value(params["sub_facet"]) || str_to_key(facet.sub_facet_name, separator: "-") if params["sub_facet"].present?
      facet
    end

  private

    def str_to_key(str, separator:)
      return nil unless str

      str.strip
        .gsub(" ", separator)
        .gsub("&", "and")
        .gsub(/[^a-zA-Z0-9_-]/, "") # remove special chars
        .delete_prefix("_")
        .delete_suffix("_")
        &.downcase
    end

    def nil_if_blank(str)
      str.presence
    end

    def nil_if_false(str)
      str == "true" ? true : nil
    end

    def facet_type(type)
      if facet_text_types.include?(type)
        "text"
      elsif facet_nested_types.include?(type)
        "nested"
      else
        type
      end
    end

    def facet_allowed_values(values, type)
      return nil if values.nil? || facet_types_that_allow_enum_values.exclude?(type)

      extract_allowed_values(values)
    end

    def extract_allowed_values(values_string)
      result = []
      current_main = nil

      values_string.each_line do |line|
        line.strip!
        next if line.blank?

        if line.start_with?("- ")
          label = extract_label(line[2..])
          value = extract_value(line[2..])
          current_main[:sub_facets] << { label:, value: } if current_main
        else
          label = extract_label(line)
          value = extract_value(line)
          current_main = { label:, value:, sub_facets: [] }
          result << current_main
        end
      end

      result.each { |value| value.delete(:sub_facets) if value[:sub_facets].blank? }
    end

    def extract_label(str)
      label = str.match(/^(.+){/)
      label.nil? ? str.strip : label[1].strip
    end

    def extract_value(str)
      str = str.to_s[0, 500] # hard truncate
      str << "}" unless str.end_with?("}")
      value = str.match(/{([^{}]*)}/)
      value.nil? ? str_to_key(str, separator: "-") : value[1].strip
    end

    def facet_specialist_publisher_properties(type, validations)
      properties = facet_specialist_publisher_properties_select(type).merge(facet_specialist_publisher_properties_validations(validations))

      properties.presence
    end

    def facet_specialist_publisher_properties_select(type)
      case type
      when "enum_text_multiple", "nested_enum_text_multiple"
        { select: "multiple" }
      when "enum_text_single", "nested_enum_text_single"
        { select: "one" }
      else
        {}
      end
    end

    def facet_specialist_publisher_properties_validations(validations)
      return {} unless validations

      rules = {}
      validations.each do |key|
        rules[key.to_sym] = {}
      end

      { validations: rules }
    end

    def facet_types_that_allow_enum_values
      facet_text_types + facet_nested_types
    end

    def facet_text_types
      %w[enum_text_multiple enum_text_single]
    end

    def facet_nested_types
      %w[nested_enum_text_multiple nested_enum_text_single]
    end
  end
end
