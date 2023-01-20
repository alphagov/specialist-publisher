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
end
