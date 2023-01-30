require "importers/licence_transaction/facet_tagger"

module Importers
  module LicenceTransaction
    class LicenceImporter
      def call
        filtered_licences.each do |licence|
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
            licence_transaction_location: [],
            licence_transaction_industry: [],
            licence_transaction_will_continue_on: details["will_continue_on"],
            licence_transaction_continuation_link: details["continuation_link"],
            licence_transaction_licence_identifier: details["licence_identifier"],
            imported: true,
          )

          new_licence.change_note = "Imported from Publisher"

          tag_licence_facets(new_licence)

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

      def common_licences_path
        Rails.root.join("lib/data/licence_transaction/common_licence_identifiers.txt")
      end

      def licences
        Services.publishing_api.get_content_items(
          document_type: "licence", page: 1, per_page: 500, states: "published",
        )["results"]
      end

      def filtered_licences
        licence_identifiers = File.new(common_licences_path).readlines(chomp: true)

        licences.select do |licence|
          licence_identifiers.include?(licence["details"]["licence_identifier"])
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

      def tag_licence_facets(licence)
        FacetTagger.new(licence).tag
      end
    end
  end
end
