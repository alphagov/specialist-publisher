module Importers
  module LicenceTransaction
    class BulkIndustrySectorsImporter
      def call
        lines = File.new(file_path).readlines(chomp: true)
        formatted = lines.map do |line|
          {
            label: line.strip.to_s,
            value: line.parameterize.to_s,
          }
        end

        formatted.as_json
      end

      def file_path
        Rails.root.join("lib/data/licence_transaction/industry_sectors.txt")
      end
    end
  end
end
