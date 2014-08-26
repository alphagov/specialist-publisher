class RenameSomeDevelopmentFundingMetadataKeys < Mongoid::Migration
  def self.up
    funds.each do |fund|
      old_fields = fund.extra_fields

      new_fields = old_fields
        .except(
          "application_state",
          "value_of_fund",
        )
        .merge(
          "fund_state" => old_fields.fetch("application_state"),
          "value_of_funding" => old_fields.fetch("value_of_fund"),
        )

      fund.extra_fields = new_fields
      fund.save!
    end
  end

  def self.down
    funds.each do |fund|
      old_fields = fund.extra_fields

      new_fields = old_fields
        .except(
          "fund_state",
          "value_of_funding",
        )
        .merge(
          "application_state" => old_fields.fetch("fund_state"),
          "value_of_fund" => old_fields.fetch("value_of_funding"),
        )

      fund.extra_fields = new_fields
      fund.save!
    end
  end

  def self.funds
    SpecialistDocumentEdition.where(
      :document_type => "international_development_fund",
      # Some imported records don't have any extra_fields yet
      :extra_fields.ne => {},
    )
  end
end
