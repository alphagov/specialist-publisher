require "csv"

module Importers
  module LicenceTransaction
    class LicenceImporter
      def call
        licences.each do |licence|
          tagging = tags_for_licence(licence["base_path"])

          unless tagging
            puts "Not imported licence as missing from tagging file: #{licence['base_path']}"
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
            licence_transaction_will_continue_on: details["will_continue_on"],
            licence_transaction_continuation_link: details["continuation_link"],
            licence_transaction_licence_identifier: details["licence_identifier"],
            imported: true,
          )

          new_licence.change_note = "Imported from Publisher"

          unless new_licence.valid?
            puts "[ERROR] licence: #{new_licence.base_path} has validation errors: #{new_licence.errors.inspect}"
            next
          end

          if new_licence_already_imported?(new_licence.base_path)
            puts "Skipping as licence: #{new_licence.base_path} is already imported"
            next
          end

          new_content_id = new_licence.content_id

          save_draft(new_licence)

          save_links(licence["content_id"], new_content_id)

          publish(new_content_id)

          puts "Published: #{new_licence.base_path}"
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
        Services.publishing_api.get_content_items(
          document_type: "licence", page: 1, per_page: 500, states: "published",
        )["results"]
      end

      def licences_tagging
        @licences_tagging ||= grouped_licences.map do |licence_url, rows|
          {
            "base_path" => URI.parse(licence_url).path,
            "locations" => locations(rows).uniq,
            "industries" => industries(rows).uniq,
          }
        end
      end

      def tags_for_licence(base_path)
        licences_tagging.find { |l| l["base_path"] == base_path }
      end

      def locations(grouped_licence)
        grouped_licence.flat_map do |licence|
          licence["Locations"].split(", ").map(&:parameterize)
        end
      end

      def industries(grouped_licence)
        grouped_licence.flat_map do |licence|
          licence[2..].compact.map(&:parameterize)
        end
      end

      def grouped_licences
        CSV.foreach(licence_tagging_path, headers: true).group_by do |licence|
          licence["Link"]
        end
      end

      def save_draft(new_licence)
        presented_licence = DocumentPresenter.new(new_licence).to_json

        Services.publishing_api.put_content(new_licence.content_id, presented_licence)
      end

      def save_links(original_content_id, new_content_id)
        original_links = Services.publishing_api.get_links(original_content_id)["links"]

        Services.publishing_api.patch_links(new_content_id, { links: original_links })
      end

      def publish(new_content_id)
        Services.publishing_api.publish(new_content_id, "republish", locale: "en")
      end
    end
  end
end
