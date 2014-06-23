class PopulateExtraFieldsForCmaCases < Mongoid::Migration
  @editions = Class.new do
    include Mongoid::Document
    store_in :specialist_document_editions
  end

  def self.up
    # For each specialist document edition which does not have extra fields
    cma_cases.where(:extra_fields.in => [nil, {}]).each do |edition|
      extra_fields = edition.attributes.slice(*extra_field_names)
      edition.update_attributes!(extra_fields: extra_fields)
    end
  end

  def self.down
    cma_cases.each do |edition|
      edition.update_attributes!(
        edition.extra_fields.merge(extra_fields: nil)
      )
    end
  end

private
  def self.extra_field_names
    %w(
      opened_date
      closed_date
      case_type
      case_state
      market_sector
      outcome_type
    )
  end

  def self.cma_cases
    @editions.where(document_type: "cma_case")
  end
end
