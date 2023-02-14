require "importers/licence_transaction/bulk_industry_sectors_importer"
require "importers/licence_transaction/licence_importer"
require "importers/licence_transaction/industry_facets_renamer"

namespace :licence_transaction do
  desc "Imports all industry sectors from file and updates the licence transaction schema"
  task :import_industry_sectors, %i[data_file_path schema_file_path] => :environment do |_, args|
    Importers::LicenceTransaction::BulkIndustrySectorsImporter.new(data_file_path: args.data_file_path, schema_file_path: args.schema_file_path).call
  end

  desc "Imports and publishes all licences identified in common_licence_identifiers.txt"
  task import_licences: :environment do
    Importers::LicenceTransaction::LicenceImporter.new.call
  end

  namespace :rename_industry_sectors do
    desc "Update licence transaction schema from file"
    task :update_schema, %i[csv_file_path schema_file_path] => :environment do |_, args|
      Importers::LicenceTransaction::IndustryFacetsRenamer.new(csv_file_path: args.csv_file_path, schema_file_path: args.schema_file_path).update_schema
    end

    desc "Re-tag licences"
    task :retag_licence_transactions, %i[csv_file_path schema_file_path] => :environment do |_, args|
      Importers::LicenceTransaction::IndustryFacetsRenamer.new(csv_file_path: args.csv_file_path, schema_file_path: args.schema_file_path).update_licence_transactions
    end
  end
end
