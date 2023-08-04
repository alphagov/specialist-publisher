require "importers/licence_transaction/bulk_industry_sectors_importer"
require "importers/licence_transaction/licence_importer"

namespace :licence_transaction do
  desc "Imports all industry sectors from file and updates the licence transaction schema"
  task :import_industry_sectors, %i[data_file_path schema_file_path] => :environment do |_, args|
    Importers::LicenceTransaction::BulkIndustrySectorsImporter.new(data_file_path: args.data_file_path, schema_file_path: args.schema_file_path).call
  end

  desc "Imports and publishes all licences identified in common_licence_identifiers.txt"
  task import_licences: :environment do
    Importers::LicenceTransaction::LicenceImporter.new.call
  end

  desc "Migrate missing archived licences"
  task migrate_missing_archived_licences: :environment do
    archived_base_paths = %w[
      /safety-certificates-for-sports-grounds
      /hazardous-waste-producer-registration-wales
      /licence-to-photograph-wildlife-northern-ireland
      /auctioneer-s-permit-firearms-and-ammunition-northern-ireland
      /chaperone-licence-northern-ireland
      /slaughterman-licence-northern-ireland
      /sqa-qualifications-approval-scotland
    ]

    missing_tagging_path = Rails.root.join("lib/data/licence_transaction/missing_licences_and_tagging.csv")
    Importers::LicenceTransaction::LicenceImporter.new(missing_tagging_path, archived_base_paths).call
  end
end
