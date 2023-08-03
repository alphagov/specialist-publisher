require "importers/licence_transaction/tagging_csv_validator"
require "csv"

module Importers
  module LicenceTransaction
    class LicenceImporter
      VALID_LINK_TYPES = %w[taxons mainstream_browse_pages].freeze

      attr_reader :tagging_path, :archived_base_paths

      def initialize(tagging_path = nil, archived_base_paths = [])
        @tagging_path = (tagging_path.presence || licence_tagging_path)
        @archived_base_paths = archived_base_paths
      end

      def call
        return tagging_csv_validator.errors unless tagging_csv_validator.valid?

        missing_licences = []
        licences.each do |licence|
          tagging = tags_for_licence(licence["base_path"])

          unless tagging
            missing_licences << licence["base_path"]
            next
          end

          details = licence["details"]
          new_licence = ::LicenceTransaction.new(
            locale: "en",
            base_path: "/find-licences#{licence['base_path']}",
            title: licence["title"],
            summary: licence["description"],
            body: details["licence_overview"].first["content"],
            publication_state: "draft",
            state_history: [],
            last_edited_at: licence["last_edited_at"],
            public_updated_at: licence["public_updated_at"],
            first_published_at: licence["first_published_at"],
            update_type: "major",
            licence_transaction_location: tagging["locations"],
            licence_transaction_industry: tagging["industries"],
            licence_transaction_will_continue_on: will_continue_on(details),
            licence_transaction_continuation_link: details["continuation_link"].presence,
            licence_transaction_licence_identifier: licence_identifier(details),
            primary_publishing_organisation: tagging["primary_publishing_organisation"],
            organisations: tagging["organisations"],
            imported: true,
          )

          new_licence.change_note = "Imported from Publisher"

          if new_licence_already_imported?(new_licence.base_path)
            puts "Skipping as licence: #{new_licence.base_path} is already imported"
            next
          end

          unless new_licence.valid?
            puts "[ERROR] licence: #{new_licence.base_path} has validation errors: #{new_licence.errors.inspect}"
            next
          end

          new_content_id = new_licence.content_id

          save_draft(new_licence)

          save_links(licence["content_id"], new_content_id, tagging)

          publish(new_content_id)

          puts "Published: #{new_licence.base_path}"
        end

        if missing_licences.present?
          puts "Missing licences from tagging file: #{missing_licences}"
        end
      end

    private

      def new_licence_already_imported?(new_licence_base_path)
        previously_imported_licence_base_paths.include?(new_licence_base_path)
      end

      def previously_imported_licences
        Services.publishing_api.get_content_items(
          document_type: "licence_transaction", page: 1, per_page: 500, states: "published",
        )["results"]
      end

      def previously_imported_licence_base_paths
        @previously_imported_licence_base_paths ||= previously_imported_licences.map do |licence|
          licence["base_path"]
        end
      end

      def licence_tagging_path
        Rails.root.join("lib/data/licence_transaction/licences_and_tagging.csv")
      end

      def licences
        if archived_base_paths.present?
          archived_licences = Services.publishing_api.get_content_items(
            document_type: "licence", page: 1, per_page: 600, states: "unpublished",
          )["results"]

          archived_licences.select { |licence| archived_base_paths.include?(licence["base_path"]) }
        else
          Services.publishing_api.get_content_items(
            document_type: "licence", page: 1, per_page: 500, states: "published",
          )["results"]
        end
      end

      def all_organisations
        # TODO: remove leading / trailing whitespace at the source (Whitehall)
        @all_organisations ||= Organisation.all.map do |o|
          Organisation.new("title" => o.title.strip, "content_id" => o.content_id)
        end
      end

      def find_organisation(csv_org_title)
        all_organisations.find { |organisation| organisation.title == csv_org_title }
      end

      def primary_publishing_organisation(ppo_titles)
        find_organisation(ppo_titles.uniq.first).content_id
      end

      def organisations(organisation_titles)
        organisation_titles.uniq.compact.flat_map { |title| find_organisation(title).content_id }
      end

      def tags_for_licence(base_path)
        tagging.find { |l| l["base_path"] == base_path }
      end

      def locations(grouped_licence)
        grouped_licence.flat_map do |licence|
          licence["Locations"].split(", ").map(&:parameterize)
        end
      end

      def industries(grouped_licence)
        grouped_licence.flat_map do |licence|
          licence[5..].compact.map(&:parameterize)
        end
      end

      def grouped_licences
        @grouped_licences ||= CSV.foreach(tagging_path, headers: true).group_by do |licence|
          licence["Link"]
        end
      end

      def save_draft(new_licence)
        presented_licence = DocumentPresenter.new(new_licence).to_json

        Services.publishing_api.put_content(new_licence.content_id, presented_licence)
      end

      def save_links(original_content_id, new_content_id, tagging)
        original_links = Services.publishing_api.get_links(original_content_id)["links"]

        filtered_links = original_links.select { |k, _| VALID_LINK_TYPES.include?(k) }

        links_with_orgs = {
          organisations: tagging["organisations"] | [tagging["primary_publishing_organisation"]],
          primary_publishing_organisation: [tagging["primary_publishing_organisation"]],
        }.merge(filtered_links)

        Services.publishing_api.patch_links(new_content_id, { links: links_with_orgs })
      end

      def publish(new_content_id)
        Services.publishing_api.publish(new_content_id, "republish", locale: "en")
      end

      def tagging
        @tagging ||= grouped_licences.map do |licence_url, rows|
          {
            "base_path" => URI.parse(licence_url).path,
            "locations" => locations(rows).uniq,
            "industries" => industries(rows).uniq,
            "primary_publishing_organisation" => primary_publishing_organisation(raw_primary_publishing_organisation(rows)),
            "organisations" => organisations(raw_organisations(rows)),
          }
        end
      end

      def raw_tagging
        grouped_licences.map do |licence_url, rows|
          {
            "base_path" => URI.parse(licence_url).path,
            "locations" => locations(rows).uniq,
            "industries" => industries(rows).uniq,
            "primary_publishing_organisation" => raw_primary_publishing_organisation(rows),
            "organisations" => raw_organisations(rows),
          }
        end
      end

      def raw_primary_publishing_organisation(rows)
        rows.filter_map { |l| l["Primary publishing organisation"]&.strip }
      end

      def raw_organisations(rows)
        rows.flat_map { |l| [l["Organisation 1"]&.strip, l["Organisation 2"]&.strip] }.compact
      end

      def tagging_csv_validator
        @tagging_csv_validator ||= TaggingCsvValidator.new(raw_tagging, all_organisations)
      end

      def licence_identifier(details)
        details["licence_identifier"] if details["continuation_link"].blank?
      end

      def will_continue_on(details)
        details["will_continue_on"] if details["continuation_link"].present?
      end
    end
  end
end
