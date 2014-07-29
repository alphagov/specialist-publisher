require "builders/international_development_fund_builder"
require "document_import"

module DfidImport
  def self.call(data_files_dir)
    DependencyContainer.new(data_files_dir).get_instance.call
  end

  class DependencyContainer
    def initialize(data_files_dir)
      @data_files_dir = data_files_dir
    end

    def get_instance
      DocumentImport::BulkImporter.new(
        import_job_builder: import_job_builder,
        data_enum: data_enum
      )
    end

  private
    def import_job_builder
      ->(data) {
        DocumentImport::SingleImport.new(
          document_creator: document_creator,
          logger: logger,
          data: data,
        )
      }
    end

    def logger
      DocumentImport::Logger.new(STDOUT)
    end

    def data_enum
      data_files.lazy.map(&method(:parse_json_file))
    end

    def data_files
      Dir.glob(File.join(@data_files_dir, "*", "*.json"))
    end

    def parse_json_file(filename)
      JSON.parse(File.read(filename)).merge ({
        "import_source" => File.dirname(filename),
      })
    end

    def document_creator
      AttachmentMapper.new(
        import_mapper,
        repo,
        logger,
      )
    end

    def import_mapper
      ->(attrs) {
        CreateDocumentService.new(
          report_builder,
          repo,
          InternationalDevelopmentFundObserversRegistry.new.creation,
          attrs,
        ).call
      }
    end

    def report_builder
      InternationalDevelopmentFundBuilder.new(
        ->(*args) {
          SlugUniquenessValidator.new(
            repo,
            SpecialistPublisherWiring.get(:validatable_international_development_fund_factory).call(*args),
          )
        },
        IdGenerator,
      )
    end

    def repo
      SpecialistPublisherWiring.get(:international_development_fund_repository)
    end
  end
end
