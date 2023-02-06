require "csv"

module Importers
  module LicenceTransaction
    class IndustryFacetsRenamer
      attr_accessor :csv_file_path

      def initialize(csv_file_path: nil)
        @csv_file_path = (csv_file_path.presence || csv_path)
      end

      def call
        parse_csv_file
      end

    private

      def parse_csv_file
        @parse_csv_file ||= begin
          industry_names = []

          CSV.foreach(csv_file_path, headers: true, col_sep: "|") do |row|
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
      end

      end

      def csv_path
        Rails.root.join("lib/data/licence_transaction/industry_sectors_new_values.csv")
      end
    end
  end
end
