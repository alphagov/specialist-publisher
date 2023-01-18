require "importers/licence_transaction/bulk_industry_sectors_importer"

namespace :licence_transaction do
  desc "Imports all industry sectors from file and updates the licence transaction schema"
  task :import_industry_sectors, %i[data_file_path schema_file_path] => :environment do |_, args|
    Importers::LicenceTransaction::BulkIndustrySectorsImporter.new(data_file_path: args.data_file_path, schema_file_path: args.schema_file_path).call
  end
end
