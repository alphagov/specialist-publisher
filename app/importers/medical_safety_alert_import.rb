require "medical_safety_alert_import/mapper"

module MedicalSafetyAlertImport
  def self.call(data_file)
    DependencyContainer.new(data_file).get_instance.call
  end

  class DependencyContainer
    def initialize(data_file)
      @data_file = data_file
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
          document_creator: import_mapper,
          logger: DocumentImport::Logger.new(STDOUT),
          data: data,
        )
      }
    end

    def data_enum
      parse_json_file(@data_file).map do |item|
        item.merge("import_source" => File.basename(@data_file))
      end
    end

    def parse_json_file(filename)
      JSON.parse(File.read(filename))
    end

    def import_mapper
      public_updated_at_setter = Proc.new { |document|
        document.latest_edition.public_updated_at = Date.parse(document.issued_date)
      }

      Mapper.new(
        ->(attrs) {
          CreateDocumentService.new(
            report_builder,
            repo,
            [],
            attrs,
          ).call
        },
        ->(document_id) {
          PublishDocumentService.new(
            repo,
            [public_updated_at_setter] + MedicalSafetyAlertObserversRegistry.new.republication,
            document_id,
            true
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
