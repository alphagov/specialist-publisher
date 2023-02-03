require "csv"

module Importers
  module LicenceTransaction
    class IndustryFacetsRenamer
      def call
        parse_csv_file
      end

    private

      def parse_csv_file
        industry_names = []

        CSV.foreach(csv_path, headers: true, col_sep: "|") do |row|
          industry_names << {
            original: {
              label: row["ORIGINAL"].strip.to_s,
              value: row["ORIGINAL"].parameterize.to_s,
            },
            new: {
              label: row["NEW"]&.strip.to_s,
              value: row["NEW"]&.parameterize.to_s,
            },
          }
        end

        industry_names
      end

      def csv_path
        Rails.root.join("lib/data/licence_transaction/industry_sectors_new_values.csv")
      end
    end
  end
end
