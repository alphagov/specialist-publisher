require "csv"

namespace :licence_reports do
  desc "CSV report on licences"
  task all: :environment do
    include OrganisationsHelper

    csv_string = CSV.generate do |csv|
      csv << %w[title link_to_competent_authority licence_identifier location publishing_organisation other_associated_organisations publication_state last_updated_at]

      LicenceTransaction.find_each do |doc|
        csv << [doc.title,
                doc.licence_transaction_continuation_link,
                doc.licence_transaction_licence_identifier,
                doc.licence_transaction_location.join(" / "),
                organisation_name(doc.primary_publishing_organisation),
                doc.organisations.map { |org| organisation_name(org) }.join(" / "),
                doc.publication_state,
                doc.public_updated_at]
      end
    end

    puts(csv_string)
  end
end
