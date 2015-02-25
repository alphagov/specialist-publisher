require "builders/specialist_document_builder"

class CmaImport
  def initialize(data_files_dir)
    @data_files_dir = data_files_dir
  end

  def call
    importer.call
  end

private
  attr_reader :data_files_dir

  def importer
    DocumentImport::BulkImporter.new(
      import_job_builder: import_job_builder,
      data_enum: data_enum,
    )
  end

  def import_job_builder
    ->(data) {
      DocumentImport::SingleImport.new(
        document_creator: create_cma_case_service,
        logger: logger,
        data: data,
      )
    }
  end

  def create_cma_case_service
    ->(attributes) {
      CreateDocumentService.new(
        cma_case_builder,
        cma_cases_repository,
        [],
        attributes,
      ).call
    }
  end

  def cma_case_builder
    SpecialistDocumentBuilder.new(
      "cma_case",
      cma_case_factory,
    )
  end

  def cma_case_factory
    ->(*args) {
      NullValidator.new(
        CmaCase.new(
          SpecialistDocument.new(
            SlugGenerator.new(prefix: "cma-cases"),
            *args,
          ),
        )
      )
    }
  end

  def cma_cases_repository
    SpecialistPublisherWiring.get(:repository_registry).for_type("cma_case")
  end

  def logger
    DocumentImport::Logger.new(STDOUT)
  end

  def data_enum
    data_files.lazy.map(&method(:parse_json_file))
  end

  def data_files
    Dir.glob(File.join(data_files_dir, "*.json")).sort.reverse
  end

  def parse_json_file(filename)
    JSON.parse(File.read(filename)).merge ({
      "import_source" => File.basename(filename),
    })
  end
end
