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
  rescue GdsApi::HTTPNotFound
    NotFoundResponseProxy.new(*args)
  rescue GdsApi::BaseError => e
    ErrorResponseProxy.new(e, *args)
  end

private
  attr_reader :api

  class ResponseProxy
    def initialize(*args)
      @args = args
    end

    def on_success(&block)
      self
    end

    def on_not_found(&block)
      self
    end

    def on_error(&block)
      self
    end
  private
    attr_reader :args
  end

  class SuccessResponseProxy < ResponseProxy
    def on_success(&block)
      block.call(*args)
      self
    end
  end

  class NotFoundResponseProxy < ResponseProxy
    def on_not_found(&block)
      block.call(*args)
      self
    end
  end

  class ErrorResponseProxy < ResponseProxy
    def on_error(&block)
      block.call(*args)
      self
    end
  end
end
