class SpecialistDocument
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  ATTRIBUTES = [
    :id,
    :title,
    :summary,
    :body,
    :opened_date,
    :closed_date,
    :case_type,
    :case_state,
    :market_sector,
    :outcome_type,
    :updated_at,
  ]

  def initialize(attributes = nil)
    attributes ||= {}

    ATTRIBUTES.each do |attribute|
      send("#{attribute}=", attributes[attribute])
    end

    @errors = Hash.new({})
  end

  attr_accessor *ATTRIBUTES
  attr_accessor :errors

  def slug
    "cma-cases/#{slug_from_title}"
  end

  def valid?
    errors.empty?
  end

  def persisted?
    id.present?
  end

  def case_type_options
    [
      ["CA98", "ca98"],
      ["Cartels", "cartels"],
      ["Criminal cartels", "criminal-cartels"],
      ["Markets", "markets"],
      ["Mergers", "mergers"],
      ["Consumer enforcement", "consumer-enforcement"],
      ["Regulatory references and appeals", "regulatory-references-and-appeals"]
    ]
  end

  def case_state_options
    [
      ["Open", "open"],
      ["Closed", "closed"]
    ]
  end

  def market_sector_options
    [
      ["Agriculture, environment and natural resources", "agriculture-environment-and-natural-resources"],
      ["Aerospace", "aerospace"],
      ["Biotechnology and pharmaceuticals", "biotechnology-and-pharmaceuticals"],
      ["Building and construction", "building-and-construction"],
      ["Chemicals", "chemicals"],
      ["Clothing, footwear and fashion", "clothing-footwear-and-fashion"],
      ["Communications", "communications"],
      ["Defence", "defence"],
      ["Distribution and Service Industries", "distribution-and-service-industries"],
      ["Electronics Industry", "electronics-industry"],
      ["Energy", "energy"],
      ["Engineering", "engineering"],
      ["Financial services", "financial-services"],
      ["Fire, police, and security", "fire-police-and-security"],
      ["Food manufacturing", "food-manufacturing"],
      ["Giftware, jewellery and tableware", "giftware-jewellery-and-tableware"],
      ["Healthcare and medical equipment", "healthcare-and-medical-equipment"],
      ["Household goods, furniture and furnishings", "household-goods-furniture-and-furnishings"],
      ["Mineral extraction, mining and quarrying", "mineral-extraction-mining-and-quarrying"],
      ["Motor Industry", "motor-industry"],
      ["Oil and Gas refining and Petrochemicals", "oil-and-gas-refining-and-petrochemicals"],
      ["Recreation and Leisure", "recreation-and-leisure"],
      ["Paper printing and packaging", "paper-printing-and-packaging"],
      ["Public markets", "public-markets"],
      ["Retail and wholesale", "retail-and-wholesale"],
      ["Telecommunications", "telecommunications"],
      ["Textiles", "textiles"],
      ["Transport", "transport"],
      ["Utilities", "utilities"]
    ]
  end

  def outcome_type_options
    [
      ["Clearance", "clearance"],
      ["Cancelled", "cancelled"],
      ["Found not to qualify", "found-not-to-qualify"],
      ["Clearance with remedies", "clearance-with-remedies"],
      ["Undertakings in lieu of reference", "undertakings-in-lieu-of-reference"],
      ["Reference to phase 2", "reference-to-phase-2"],
      ["Prohibition", "prohibition"],
      ["Remittals", "remittals"],
      ["Review of orders and undertakings", "review-of-orders-and-undertakings"],
      ["Report to Secretary of State", "report-to-secretary-of-state"]
    ]
  end

protected

  def slug_from_title
    title.downcase.gsub(/\W/, '-')
  end
end
