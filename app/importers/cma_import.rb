require "builders/specialist_document_builder"
require "cma_import/mapper"
require "cma_import/attachment_attacher"
require "cma_import/missing_body_generator"
require "cma_import/body_fixer"

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
        document_creator: missing_body_generator,
        logger: logger,
        data: data,
      )
    }
  end

  def missing_body_generator
    CmaImportMissingBodyGenerator.new(
      create_document_service: body_fixer,
      document_repository: cma_cases_repository,
    )
  end

  def body_fixer
    CmaImportBodyFixer.new(
      create_document_service: attachment_attacher,
    )
  end

  def attachment_attacher
    CmaImportAttachmentAttacher.new(
      create_document_service: attribute_mapper,
      document_repository: cma_cases_repository,
      assets_directory: data_files_dir,
    )
  end

  def attribute_mapper
    CmaImportAttributeMapper.new(create_cma_case_service)
  end

  def create_cma_case_service
    ->(attributes) {
      DocumentPresenter.new(
        CreateDocumentService.new(
          cma_case_builder,
          cma_cases_repository,
          [],
          attributes,
        ).call
      )
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

  class DocumentPresenter < SimpleDelegator
    def import_notes
      [
        "id: #{id}",
        "publisher_url: #{publisher_url}",
        "slug: #{slug}",
      ]
    end

  private
    def publisher_url
      "#{publisher_host}/cma-cases/#{id}"
    end

    def publisher_host
      Plek.new.find("specialist-publisher")
    end
  end
end
