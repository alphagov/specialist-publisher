require "csv"

module Importers
  module LicenceTransaction
    class IndustryFacetsRenamer
      attr_accessor :csv_file_path, :schema_file_path

      def initialize(csv_file_path: nil, schema_file_path: nil)
        @csv_file_path = (csv_file_path.presence || csv_path)
        @schema_file_path = (schema_file_path.presence || schema_path)
      end

      def call
        parse_csv_file
      end

      def changing_industry_values
        @changing_industry_values ||= begin
          industry_values = []
          parse_csv_file.filter_map do |industry|
            industry_values << industry[:original][:value] if industry[:new][:value].present?
          end

          industry_values
        end
      end

      def update_schema
        json_blob = File.new(schema_file_path).read
        schema = JSON.parse(json_blob)
        licence_transaction_industry = schema["facets"].select { |facet| facet["key"] == "licence_transaction_industry" }
        licence_transaction_industry.first["allowed_values"] = new_industry_sectors_schema

        File.write(schema_file_path, JSON.dump(schema))
      end

    private

      def new_industry_sectors_schema
        parse_csv_file.map do |industry|
          if industry[:new][:value].present?
            {
              label: industry[:new][:label].strip,
              value: industry[:new][:value],
            }
          else
            {
              label: industry[:original][:label].strip,
              value: industry[:original][:value],
            }
          end
        end
      end

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

      def schema_path
        Rails.root.join("lib/documents/schemas/licence_transactions.json")
      end

      def csv_path
        Rails.root.join("lib/data/licence_transaction/industry_sectors_new_values.csv")
      end
    end
  end
end
