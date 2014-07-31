require "aaib_import/mapper"
require "aaib_import/attachment_mapper"

module AaibImport
  def self.call(data_files_dir, attachments_dir)
    DependencyContainer.new(
      data_files_dir,
      attachments_dir,
    )
    .get_instance
    .call
  end

  class DependencyContainer
    def initialize(data_files_dir, attachments_dir)
      @data_files_dir = data_files_dir
      @attachments_dir = attachments_dir
    end

    def get_instance
      DocumentImport::BulkImporter.new(
        import_job_builder: import_job_builder,
        data_enum: data_enum,
      )
    end

    private

    def import_job_builder
      ->(data) {
        DocumentImport::SingleImport.new(
          document_creator: document_creator,
          logger: DocumentImport::Logger.new(STDOUT),
          data: data,
        )
      }
    end

    def data_enum
      data_files.lazy.map(&method(:parse_json_file))
    end

    def data_files
      Dir.glob(File.join(@data_files_dir, "*.json"))
    end

    def parse_json_file(filename)
      JSON.parse(File.read(filename)).merge ({
        "import_source" => File.basename(filename),
      })
    end

    def document_creator
      AttachmentMapper.new(
        import_mapper,
        repo,
        @attachments_dir,
      )
    end

    def import_mapper
      Mapper.new(
        ->(attrs) {
          CreateDocumentService.new(
            report_builder,
            repo,
            AaibReportObserversRegistry.new.creation,
            attrs,
          ).call
        },
        repo,
      )
    end

    def report_builder
      AaibReportBuilder.new(
        ->(*args) {
          SlugUniquenessValidator.new(
            repo,
            null_validator(
              SpecialistPublisherWiring.get(:aaib_report_factory).call(*args),
            )
          )
        },
        IdGenerator,
      )
    end

    def repo
      SpecialistPublisherWiring.get(:aaib_report_repository)
    end

    def null_validator(thing)
      NullValidator.new(thing)
    end
  end
end
