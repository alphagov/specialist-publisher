class GdsApiProxy
  def initialize(api)
    @api = api
  end

  def respond_to_missing?(method_id)
    api.respond_to?(method_id)
  end

  def method_missing(method_id, *args, &block)
    return super unless respond_to_missing?(method_id)

    response = api.public_send(method_id, *args, &block)

    SuccessResponseProxy.new(response)
  rescue GdsApi::BaseError => e
    ErrorResponseProxy.new(e, *args)
  end

private
  attr_reader :api

  module ResponseProxy
    def on_success(&block)
      self
    end

    def on_error(&block)
      self
    end
  end

  class SuccessResponseProxy
    include ResponseProxy

    def initialize(response)
      @response = response
    end

    def on_success(&block)
      block.call(@response)
      self
    end
  end

  class ErrorResponseProxy
    include ResponseProxy

    def initialize(*args)
      @args = args
    end

    def on_error(&block)
      block.call(*@args)
      self
    end
  end
end
