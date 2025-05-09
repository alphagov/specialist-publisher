class FinderSchema
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Serializers::JSON
  extend ActiveModel::Callbacks

  define_model_callbacks :update

  after_update :remove_empty_related_links, :remove_empty_organisations

  # Pluralized names of all document types
  def self.schema_names
    Dir.glob(Rails.root.join("lib/documents/schemas/*.json")).map do |f|
      File.basename(f).gsub(".json", "")
    end
  end

  def self.load_from_schema(type)
    new.from_json(File.read(Rails.root.join("lib/documents/schemas/#{type}.json")))
  end

  def self.document_models
    schema_names.map do |schema_name|
      schema_name.singularize.camelize.constantize
    end
  end

  attribute :base_path
  attribute :beta
  attribute :beta_message
  attribute :content_id
  attribute :default_order
  attribute :description
  attribute :document_noun
  attribute :document_title
  attribute :editing_organisations, default: []
  attribute :email_filter_options
  attribute :facets, default: []
  attribute :filter
  attribute :show_table_of_contents, :boolean, default: false
  attribute :label_text
  attribute :name
  attribute :organisations, default: []
  attribute :open_filter_on_load
  attribute :parent
  attribute :phase
  attribute :related
  attribute :show_summaries, :boolean, default: false
  attribute :show_metadata_block, :boolean, default: false
  attribute :signup_content_id
  attribute :signup_link
  attribute :subscription_list_title_prefix
  attribute :summary, default: ""
  attribute :target_stack
  attribute :taxons, default: []
  attribute :topics, default: []

  def update(attributes)
    run_callbacks :update do
      assign_attributes(attributes)
    end
  end

  def as_json(options = nil)
    super.compact.reject { |_k, v| v.blank? }
  end

  def format
    filter["format"]
  end

  def remove_empty_organisations
    organisations.reject!(&:blank?)
  end

  def remove_empty_related_links
    related&.reject!(&:blank?)
  end

  def humanized_facet_value(facet_key, value)
    type = facet_data_for(facet_key).fetch("type", nil)
    if %w[text nested].include?(type) && allowed_values_for(facet_key).empty?
      value
    elsif %w[hidden text nested].include?(type)
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

  def allowed_values_for(facet_name)
    facet_data_for(facet_name).fetch("allowed_values", [])
  end

  def nested_facets
    facets.select { |facet| facet["type"] == "nested" }
  end

private

  def facet_data_for(facet_name)
    parent_facet = facets.find do |facet_record|
      facet_record.fetch("key") == facet_name.to_s
    end || {}

    return parent_facet if parent_facet.any?

    facet_data_for_nested(facet_name)
  end

  def facet_data_for_nested(facet_key)
    parent_facet = facets.select { |f| f["sub_facet_key"] == facet_key.to_s }.first

    return {} unless parent_facet

    allowed_values = []
    parent_facet["allowed_values"].map do |allowed_value|
      parent_label = allowed_value["label"]
      allowed_value["sub_facets"]&.map do |sub_facet|
        allowed_values << {
          "label" => "#{parent_label} - #{sub_facet['label']}",
          "value" => sub_facet["value"],
        }
      end
    end

    {
      "key" => facet_key.to_s,
      "allowed_values" => allowed_values.flatten.compact,
      "name" => parent_facet["sub_facet_name"],
      "type" => parent_facet["type"],
    }
  end

  def value_label_mapping_for(facet_key, value)
    allowed_values_for(facet_key).find do |allowed_value|
      allowed_value.fetch("value") == value.to_s
    end || {}
  end
end
