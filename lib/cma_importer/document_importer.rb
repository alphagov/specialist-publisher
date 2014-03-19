module CMAImporter
  class DocumentImporter
    def initialize(content_directory, case_data)
      @content_directory = content_directory
      @case_data = case_data.dup

      @case_data.each do |k, v|
        @case_data.delete(k) if v.blank?
      end

      @case_data['original_urls'] ||= Array(@case_data.delete('original_url'))
    end

    attr_reader :case_data, :content_directory

    def import
      presenter = CMAImporter::ImportedSpecialistDocumentPresenter.new(case_data)

      builder = SpecialistPublisherWiring.get(:specialist_document_builder)
      document = builder.call(presenter.to_hash)

      repository = SpecialistPublisherWiring.get(:specialist_document_repository)
      unless repository.store!(document)
        raise "Failed to store document, #{document.errors}"
      end

      mapping = SpecialistPublisherWiring.get(:panopticon_mappings).where(document_id: document.id).last
      mapping.update_attribute(:original_urls, case_data['original_urls'])

      Array(case_data['assets']).each do |asset_data|
        basename = asset_data['filename'].split('/').last
        puts "-- Adding asset #{basename}"

        file = File.open(content_directory + asset_data['filename'])
        uploaded_file = ActionDispatch::Http::UploadedFile.new(
          tempfile: file,
          filename: basename,
          type: asset_data['content_type']
        )

        asset_url = asset_data['original_url']
        asset_path = URI.parse(asset_url).path

        asset_title = presenter.attachment_titles[asset_path] ||
                      presenter.attachment_titles[asset_url] ||
                      basename

        document.add_attachment(
          file: uploaded_file,
          filename: basename,
          title: asset_title,
          original_url: asset_url
        )

        if repository.store!(document)
          puts "---- OK"
        else
          puts "---- FAILED to store because #{document.errors.full_messages.to_sentence}"
        end

        file.close
      end
    end
  end
end
