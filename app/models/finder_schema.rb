class FinderSchema
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Serializers::JSON

  # Pluralized names of all document types
  def self.schema_names
    Dir.glob(Rails.root.join("lib/documents/schemas/*.json")).map do |f|
      File.basename(f).gsub(".json", "")
    end
  end

  def self.load_from_schema(type)
    new.from_json(File.read(Rails.root.join("lib/documents/schemas/#{type}.json")))
  end

  attribute :show_summaries, :boolean, default: false
  attr_writer :editing_organisations, :facets, :taxons
  attr_reader :document_noun, :related
  attr_accessor :base_path,
                :beta,
                :beta_message,
                :content_id,
                :default_order,
                :description,
                :document_title,
                :email_filter_by,
                :email_filter_facets,
                :filter,
                :format_name,
                :label_text,
                :name,
                :open_filter_on_load,
                :parent,
                :phase,
                :signup_content_id,
                :signup_copy,
                :signup_link,
                :subscription_list_title_prefix,
                :summary,
                :target_stack,
                :topics

  def document_noun=(noun)
    @document_noun = noun
    if @signup_copy.present?
      @signup_copy = "You'll get an email each time a #{noun} is updated or a new #{noun} is published."
    end
  end

  def format
    @filter["format"]
  end

  def taxons
    @taxons || []
  end

  def organisations
    @organisations || []
  end

  def organisations=(value)
    @organisations = value.reject(&:empty?)
  end

  def editing_organisations
    @editing_organisations || []
  end

  def related=(value)
    @related = value.nil? ? nil : value.reject(&:empty?)
  end

  def facets
    @facets.map { |facet| facet["key"].to_sym }
  end

  def email_alerts=(value)
    @signup_content_id = if value == "no"
                           nil
                         else
                           @signup_content_id || SecureRandom.uuid
                         end
  end

  def options_for(facet_name)
    allowed_values_as_option_tuples(allowed_values_for(facet_name))
  end

  def humanized_facet_value(facet_key, value)
    type = facet_data_for(facet_key).fetch("type", nil)
    if type == "text" && allowed_values_for(facet_key).empty?
      value
    elsif %w[hidden text].include?(type)
      Array(value).map do |v|
        value_label_mapping_for(facet_key, v).fetch("label") { value }
      end
    else
      value_label_mapping_for(facet_key, value).fetch("label") { value }
    end
  end

  def humanized_facet_name(key)
    facet_data_for(key).fetch("name") { key.to_s.humanize }
  end

private

  def facet_data_for(facet_name)
    (@facets || []).find do |facet_record|
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
        value.fetch("value", ""),
      ]
    end
  end

  def value_label_mapping_for(facet_key, value)
    allowed_values_for(facet_key).find do |allowed_value|
      allowed_value.fetch("value") == value.to_s
    end || {}
  end
end
