class SpecialistDocumentBulkImporter
  def initialize(dependencies)
    @import_job_builder = dependencies.fetch(:import_job_builder)
    @data_loader = dependencies.fetch(:data_loader)
  end

  def call(data_collection)
    data_collection.to_enum.lazy
      .map { |data| data_loader.call(data) }
      .map { |data| import_job_builder.call(data) }
      .each(&:call)
  end

private
  attr_reader :import_job_builder, :data_loader
end

class DocumentImportLogger
  def initialize(output)
    @output = output
  end

  def success(document, duration)
    @output.puts("SUCCESS: Created #{document.slug} [took #{duration}s]")
  end

  # Failure.. Unless it's only failing on summary, in which case it's a..
  # SUCCESS
  def failure(document, duration)
    return success(document, duration) if document.errors.keys == [:summary]
    errors = document.errors.to_h
    errors.delete(:summary)

    @output.puts("FAILURE: #{document.slug} #{errors} [took #{duration}s]")
  end
end

class SingleImport
  def initialize(dependencies)
    @document_creator = dependencies.fetch(:document_creator)
    @logger = dependencies.fetch(:logger)
    @data = dependencies.fetch(:data)
  end

  def call
    if document.valid?
      logger.success(document, duration)
    else
      logger.failure(document, duration)
    end
  end

  private

  attr_reader :document_creator, :logger, :data, :duration

  def document
    return @document if @document

    @duration = Benchmark.realtime do
      @document = document_creator.call(data)
    end

    @document
  end
end
