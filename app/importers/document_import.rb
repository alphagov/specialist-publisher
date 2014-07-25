module DocumentImport
  class HasNewerVersionError < StandardError; end

  class BulkImporter
    def initialize(dependencies)
      @import_job_builder = dependencies.fetch(:import_job_builder)
      @data_enum = dependencies.fetch(:data_enum)
    end

    def call
      data_enum.lazy
        .map { |data| import_job_builder.call(data) }
        .each(&:call)
    end

  private
    attr_reader :import_job_builder, :data_enum
  end

  class Logger
    def initialize(output)
      @output = output
    end

    def success(document, data)
      @output.puts("SUCCESS: Created #{document.slug} #{format_data(data)}")
    end

    # Failure.. Unless it's only failing on summary, in which case it's a..
    # SUCCESS
    def failure(document, data)
      errors = document.errors.to_h

      @output.puts("FAILURE: #{document.slug} #{errors} #{format_data(data)}")
    end

    def error(message, data)
      @output.puts("ERROR: #{message} #{format_data(data)}")
    end

    def skipped(message, data)
      @output.puts("SKIPPED: #{message} #{format_data(data)}")
    end

  private

    def format_data(data)
      data.map { |kv| kv.join(": ") }.join(", ")
    end
  end

  class SingleImport
    def initialize(dependencies)
      @document_creator = dependencies.fetch(:document_creator)
      @logger = dependencies.fetch(:logger)
      @data = dependencies.fetch(:data)
      @duration = "unknown"
    end

    def call
      import_with_benchmark

      if document.valid?
        logger.success(document, logger_metadata)
      else
        logger.failure(document, logger_metadata)
      end
    rescue HasNewerVersionError => e
      logger.skipped(e.message, logger_metadata)
    rescue Object => e # ALL THE THINGS
      logger.error(e.message, logger_metadata)
    end

    private

    attr_reader :document_creator, :logger, :data, :duration

    def logger_metadata
      {duration: duration, source: data["import_source"]}
    end

    def document
      @document ||= document_creator.call(data)
    end

    def import_with_benchmark
      seconds = Benchmark.realtime { document }
      @duration = (seconds * 1000).round.to_s + "ms"
    end
  end
end
