class BusinessFinanceSupportSchemeExportPresenter
  attr_reader :document

  def self.header_row
    [
      "Title",
      "Web URL",
      "Summary",
      "Body",
      finder_schema.humanized_facet_name("continuation_link"),
      finder_schema.humanized_facet_name("will_continue_on"),
      finder_schema.humanized_facet_name("business_sizes"),
      finder_schema.humanized_facet_name("business_stages"),
      finder_schema.humanized_facet_name("industries"),
      finder_schema.humanized_facet_name("regions"),
      finder_schema.humanized_facet_name("types_of_support"),
    ]
  end

  def initialize(document)
    @document = document
  end

  def row
    [
      document.title,
      URI.join(Plek.website_root, document.base_path).to_s,
      document.summary,
      document.body,
      document.continuation_link,
      document.will_continue_on,
      finder_schema.humanized_facet_value("business_sizes", document.business_sizes).join(";"),
      finder_schema.humanized_facet_value("business_stages", document.business_stages).join(";"),
      finder_schema.humanized_facet_value("industries", document.industries).join(";"),
      finder_schema.humanized_facet_value("regions", document.regions).join(";"),
      finder_schema.humanized_facet_value("types_of_support", document.types_of_support).join(";"),
    ]
  end

  def self.finder_schema
    BusinessFinanceSupportScheme.finder_schema
  end

  delegate :finder_schema, to: :class
end
