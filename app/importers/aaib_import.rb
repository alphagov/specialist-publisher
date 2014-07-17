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
        data_loader: data_loader,
        data_collection: data_files,
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

    def data_files
      Dir.glob(File.join(@data_files_dir, "*.json"))
    end

    def data_loader
      ->(file) {
        JSON.parse(File.read(file))
      }
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
            SpecialistPublisherWiring.get(:observers).aaib_report_creation,
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
            SpecialistPublisherWiring.get(:aaib_report_factory).call(*args),
          )
        },
        IdGenerator,
      )
    end

    def repo
      SpecialistPublisherWiring.get(:aaib_report_repository)
    end
  end
end
