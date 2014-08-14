require "gds_api/panopticon"

class PanopticonRegisterer
  def initialize(dependencies)
    @artefact = dependencies.fetch(:artefact)
    @api = dependencies.fetch(:api)
    @error_logger = dependencies.fetch(:error_logger)
  end

  def call
    create_or_update_artefact

    nil
  end

private
  attr_reader :artefact, :api, :error_logger

  def create_or_update_artefact
    api
      .artefact_for_slug(slug)
      .on_success { |_response| notify_of_update } # TODO Check owning app is "specialist-publisher"
      .on_not_found { |*_| register_new_artefact }
      .on_error(&method(:handle_error))
  end

  def register_new_artefact
    api
      .create_artefact!(artefact_attributes)
      .on_error(&method(:handle_error))
  end

  def notify_of_update
    api
      .put_artefact!(slug, artefact_attributes)
      .on_error(&method(:handle_error))
  end

  def handle_error(error, *_api_args)
    error_logger.call(error)

    case error.code.to_i
    when (400..499)
      raise ClientError.new("Panopticon responded with #{error.code}", error)
    when (500..599)
      raise ServerError.new("Panopticon responded with #{error.code}", error)
    else
      raise HTTPError.new("Panopticon responded with #{error.code}", error)
    end
  end

  def slug
    artefact.slug
  end

  def artefact_attributes
    artefact.attributes.merge(
      owning_app: owning_app,
    )
  end

  def owning_app
    "specialist-publisher"
  end

  class HTTPError < StandardError
    attr_reader :original_exception

    def initialize(message, original_exception = nil)
      super(message)
      @original_exception = original_exception
    end
  end

  class ClientError < HTTPError
  end

  class ServerError < HTTPError
  end
end
