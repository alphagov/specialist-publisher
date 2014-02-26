require "forwardable"

class SpecialistDocument
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  extend Forwardable

  def self.edition_attributes
    [
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
  end

  def_delegators :latest_edition, *edition_attributes

  attr_reader :id, :editions

  def initialize(id, editions)
    @id = id
    @editions = editions.sort_by(&:version_number)
  end

  # TODO: Remove factory methods
  def self.create(params)
    editions = [new_edition(params.merge(version_number: 1))]
    new(SecureRandom.uuid, editions)
  end

  def self.new_edition(params)
    edition_params = {version_number: 1}.merge(params).merge(state: 'draft')
    SpecialistDocumentEdition.new(edition_params)
  end

  def update(params)
    if latest_edition.published?
      editions.push(new_edition(params))
    else
      latest_edition.assign_attributes(params)
    end

    self
  end

  def slug
    "cma-cases/#{slug_from_title}"
  end

  def valid?
    latest_edition.valid?
  end

  def published?
    editions.any?(&:published?)
  end

  def draft?
    latest_edition.draft?
  end

  def errors
    latest_edition.errors.messages
  end

  def add_error(field, message)
    latest_edition.add_error(field, message)
  end

  def latest_edition
    @editions.last
  end

  # TODO: remove this persistence concern
  def persisted?
    updated_at.present?
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

  def new_edition(params)
    self.class.new_edition(params.merge(version_number: current_version_number + 1))
  end

  def current_version_number
    latest_edition.version_number
  end
end
