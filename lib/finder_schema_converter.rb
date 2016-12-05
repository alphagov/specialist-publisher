# FinderSchemaConverter looks at the finder content schemas, and generates
# The corresponding metadata fields we would expect to see in the content
# schema for `specialist_document`.
#
# The specialist document schema is used for all document types that can be
# found by the finders, and it should have fields for everything that can be
# facetted on.
class FinderSchemaConverter
  MULTI_SELECTS_BY_DOCUMENT_TYPE = {
    "aaib_report" => %w[aircraft_category].freeze,
    "cma_case" => %w[market_sector].freeze,
    "countryside_stewardship_grant" => %w[
      land_use
      tiers_or_standalone_items
      funding_amount
    ].freeze,
    "drug_safety_update" => %w[therapeutic_area].freeze,
    "european_structural_investment_fund" => %w[
      fund_type
      location
      funding_source
    ].freeze,
    "international_development_fund" => %w[
      location
      development_sector
      eligible_entities
      value_of_funding
    ].freeze,
    "maib_report" => %w[vessel_type].freeze,
    "medical_safety_alert" => %w[medical_specialism].freeze,
    "raib_report" => %w[railway_type].freeze,
  }.freeze

  SCHEMA_FILES = Dir[File.dirname(__FILE__) + "/documents/schemas/*.json"]

  # The facets in these finders do not completely match the specialist document
  # metadata schema. The finders can still work because finders use rummager
  # to work out whether a document matches a facet, rather than whats in the
  # content store.
  IGNORED_FINDERS = %w(
    asylum_support_decision
    dfid_research_output
    employment_appeal_tribunal_decision
    employment_tribunal_decision
    tax_tribunal_decision
    utaac_decision
    vehicle_recalls_and_faults_alert
  ).freeze

  def self.all
    SCHEMA_FILES.map { |file| FinderSchema.new(file) }
  end

  def self.except_ignored_finders
    all.reject { |schema| IGNORED_FINDERS.include?(schema.document_type) }
  end

  class FinderSchema
    attr_reader :file

    def initialize(file)
      @file = file
    end

    def definition
      {
        definition_name => {
          "type" => "object",
          "additionalProperties" => false,
          "properties" => properties
        }
      }
    end

    def definition_name
      "#{document_type}_metadata"
    end

    def select_field_multiplicity_identifier(document_type, facet_name)
      MULTI_SELECTS_BY_DOCUMENT_TYPE.fetch(document_type, []).include?(facet_name)
    end

    def document_type
      data["filter"]["document_type"]
    end

    def properties
      facets.map(&:as_json_schema).inject(:merge)
    end

    def facets
      data["facets"].map do |facet_json|
        FinderFacet.type_of(
          is_multiple_values: select_field_multiplicity_identifier(document_type, facet_json["key"]),
          json: facet_json
        ).new(facet_json)
      end
    end

    def data
      @data ||= JSON.parse(File.read(file))
    end
  end

  class FinderFacet
    attr_reader :json

    def self.type_of(is_multiple_values:, json:)
      if json["type"] == "text" && json.has_key?("allowed_values")
        if is_multiple_values
          FinderArrayFacet
        else
          FinderSingleSelectFacet
        end
      elsif json["type"] == "text"
        FinderStringFacet
      elsif json["type"] == "date"
        FinderDateFacet
      else
        raise "Unknown finder facet type #{json['type']}"
      end
    end

    def initialize(json)
      @json = json
    end

    def facet_name
      json["key"]
    end
  end

  class FinderArrayFacet < FinderFacet
    def as_json_schema
      {
        facet_name => {
          "type" => "array",
          "items" => {
            "type" => "string",
            "enum" => allowed_values
          }
        }
      }
    end

    def allowed_values
      json["allowed_values"].map { |record| record["value"] }
    end
  end

  class FinderSingleSelectFacet < FinderFacet
    def as_json_schema
      {
        facet_name => {
          "type" => "string",
          "enum" => allowed_values
        }
      }
    end

    def allowed_values
      json["allowed_values"].map { |record| record["value"] }
    end
  end

  class FinderDateFacet < FinderFacet
    def as_json_schema
      {
        facet_name => {
          "type" => "string",
          "pattern" => "^[1-9][0-9]{3}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[0-1])$"
        }
      }
    end
  end

  class FinderStringFacet < FinderFacet
    def as_json_schema
      {
        facet_name => {
          "type" => "string"
        }
      }
    end
  end
end
