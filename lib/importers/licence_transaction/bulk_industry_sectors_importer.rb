module Importers
  module LicenceTransaction
    class BulkIndustrySectorsImporter
      def call
        update_industry_sectors_in_schema(imported_json_data)
      end

      def imported_json_data
        lines = File.new(file_path).readlines(chomp: true)
        formatted = lines.map do |line|
          {
            label: line.strip.to_s,
            value: line.parameterize.to_s,
          }
        end

        formatted.as_json
      end

      def update_industry_sectors_in_schema(industry_sectors)
        json_blob = File.new(schema_path).read
        schema = JSON.parse(json_blob)
        licence_transaction_industry = schema["facets"].select { |facet| facet["key"] == "licence_transaction_industry" }
        licence_transaction_industry.first["allowed_values"] = industry_sectors

        File.write(schema_path, JSON.dump(schema))
      end

      def file_path
        Rails.root.join("lib/data/licence_transaction/industry_sectors.txt")
      end

      def schema_path
        Rails.root.join("lib/documents/schemas/licence_transactions.json")
      end
    end
  end
end
