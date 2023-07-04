module Importers
  module LicenceTransaction
    class TaggingCsvValidator
      attr_reader :licences_tagging, :organisations

      def initialize(licences_tagging, organisations)
        @licences_tagging = licences_tagging
        @organisations = organisations
      end

      def valid?
        tagging_validation_errors.empty?
      end

      def errors
        return if valid?

        tagging_validation_errors.each { |e| puts e }
        puts unrecognised_tags_instructions
      end

    private

      def tagging_validation_errors
        @tagging_validation_errors ||=
          licences_tagging.filter_map do |tagging|
            errors = [
              industry_errors(tagging),
              location_errors(tagging),
              primary_publishing_organisation_errors(tagging),
              organisations_errors(tagging),
            ].compact

            if errors.present?
              combined_errors = errors.join("\n- ")

              "CSV errors for '#{tagging['base_path']}':\n- #{combined_errors}\n\n"
            end
          end
      end

      def primary_publishing_organisation_errors(tagging)
        ppo = tagging["primary_publishing_organisation"].uniq

        if ppo.blank?
          return "primary publishing organisation blank"
        end

        if ppo.count > 1
          return "more than one primary publishing organisation: '#{ppo}'"
        end

        if validated_organisations(ppo).blank?
          "primary publishing organisation doesn't exist: '#{ppo}'"
        end
      end

      def organisations_errors(tagging)
        return if tagging["organisations"].blank?

        unrecognised_organisations = tagging["organisations"] - validated_organisations(tagging["organisations"])

        return if unrecognised_organisations.blank?

        "organisations don't exist: '#{unrecognised_organisations}'"
      end

      def industry_errors(tagging)
        unrecognised_industries = tagging["industries"] - schema_values["licence_transaction_industry"]

        return if unrecognised_industries.empty?

        "unrecognised industries: '#{unrecognised_industries}'"
      end

      def location_errors(tagging)
        unrecognised_locations = tagging["locations"] - schema_values["licence_transaction_location"]

        return if unrecognised_locations.empty?

        "unrecognised locations: '#{unrecognised_locations}'"
      end

      def schema_values
        @schema_values ||= parsed_licence_schema["facets"].each_with_object({}) do |facet, hash|
          if %w[licence_transaction_industry licence_transaction_location].include?(facet["key"])
            hash[facet["key"]] = facet["allowed_values"].map { |v| v["value"] }
          end
        end
      end

      def parsed_licence_schema
        schema_file_path = Rails.root.join("lib/documents/schemas/licence_transactions.json")
        json_blob = File.new(schema_file_path).read
        JSON.parse(json_blob)
      end

      def validated_organisations(organisation_titles)
        organisation_titles.select { |title| all_organisation_titles.include?(title) }
      end

      def all_organisation_titles
        @all_organisation_titles ||= organisations.map(&:title)
      end

      def unrecognised_tags_instructions
        <<~HEREDOC
          Please read the instructions (under heading 'Update tagging') in the following link to resolve the unrecognised
          tags errors: https://trello.com/c/2SBbuD8N/1969-how-to-correct-unrecognised-tags-when-importing-licences
        HEREDOC
      end
    end
  end
end
