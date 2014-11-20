require "medical_safety_alert_import/mapper"
require "medical_safety_alert_import/attachment_mapper"

module MedicalSafetyAlertImport
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
      Dir.glob(File.join(@data_files_dir, "*.json")).sort.reverse
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
            MedicalSafetyAlertObserversRegistry.new.creation,
            attrs,
          ).call
        },
        repo,
      )
    end

    def report_builder
      SpecialistDocumentBuilder.new("medical_safety_alert",
        ->(*args) {
          null_validator(
            SpecialistPublisherWiring
            .get(:validatable_document_factories)
            .medical_safety_alert_factory
            .call(*args)
          )
        }
      )
    end

    def repo
      SpecialistPublisherWiring.get(:repository_registry).for_type("medical_safety_alert")
    end

    def null_validator(thing)
      NullValidator.new(thing)
    end
  end
end
