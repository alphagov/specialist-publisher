module DocumentImport
  class HasNewerVersionError < StandardError; end
  class FileNotFound < StandardError; end

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
      import_notes = document.respond_to?(:import_notes) ? document.import_notes : []
      write("SUCCESS", import_notes.join("\t"), data)
    end

    def failure(document, data)
      write("FAILURE", document.errors.to_h, data)
    end

    def error(message, data)
      write("ERROR", message, data)
    end

    def warn(message, data)
      write("WARNING", message, data)
    end

    def skipped(message, data)
      write("SKIPPED", message, data)
    end

  private
    def write(status, message, data)
      line = [
        status,
        message,
        format_data(data),
      ].join("\t")

      @output.puts(line)
    end

    def format_data(data)
      data.map { |kv| kv.join(": ") }.join("\t")
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
