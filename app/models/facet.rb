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
      facet.key = facet_key(params["key"], params["name"])
      facet.name = params["name"]
      facet.short_name = nil_if_blank(params["short_name"])
      facet.type = facet_type(params["type"])
      facet.preposition = nil_if_blank(params["preposition"])
      facet.display_as_result_metadata = params["display_as_result_metadata"]
      facet.filterable = params["filterable"]
      facet.allowed_values = facet_allowed_values(params["allowed_values"], params["type"])
      facet.specialist_publisher_properties = facet_specialist_publisher_properties(params["type"], params["validations"])
      facet.show_option_select_filter = nil_if_false(params["show_option_select_filter"])
      facet.sub_facet_name = extract_label_and_value(params["sub_facet"], "_").first if params["sub_facet"].present?
      facet.sub_facet_key = facet_key(extract_label_and_value(params["sub_facet"], "_").last, facet.sub_facet_name) if params["sub_facet"].present?
      facet
    end

  private

    def facet_key(key, name)
      key.presence || name&.gsub(" ", "")&.underscore
    end

    def nil_if_blank(str)
      str.presence
    end

    def nil_if_false(str)
      str == "true" ? true : nil
    end

    def facet_type(type)
      facet_text_types.include?(type) ? "text" : type
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
          label, value = extract_label_and_value(line[2..], "-")
          current_main[:sub_facets] << { label:, value: } if current_main
        else
          label, value = extract_label_and_value(line, "-")
          current_main = { label:, value:, sub_facets: [] }
          result << current_main
        end
      end

      result.each { |value| value.delete(:sub_facets) if value[:sub_facets].blank? }
    end

    def extract_label_and_value(str, gsub_character)
      label = str.match(/^(.+){/)
      label = label.nil? ? str.strip : label[1].strip
      value = str.truncate(500, omission: "}").match(/{(.+)}/)
      value = value.nil? ? str.strip.downcase.gsub(/[^\w\d\s]/, "").gsub(/\s/u, gsub_character) : value[1].strip

      [label, value]
    end

    def facet_specialist_publisher_properties(type, validations)
      properties = facet_specialist_publisher_properties_select(type).merge(facet_specialist_publisher_properties_validations(validations))

      properties.presence
    end

    def facet_specialist_publisher_properties_select(type)
      case type
      when "enum_text_multiple", "nested"
        { select: "multiple" }
      when "enum_text_single"
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
      facet_text_types + %w[nested]
    end

    def facet_text_types
      %w[enum_text_multiple enum_text_single]
    end
  end
end
