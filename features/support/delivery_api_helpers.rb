require "singleton"

module DeliveryAPIHelpers

  class FakeDeliveryAPI
    include Singleton

    def notify(feed_urls, subject, body)
    end

    def topic(feed_urls, title)
    end
  end

  def stub_delivery_api
    allow(GdsApi::GovUkDelivery).to receive(:new)
      .and_return(fake_delivery_api)

    allow(fake_delivery_api).to receive(:notify).and_call_original
    allow(fake_delivery_api).to receive(:topic).and_call_original
  end

  def reset_delivery_api_stubs_and_messages
    RSpec::Mocks.space.proxy_for(delivery_api).reset
    stub_delivery_api
  end

  def fake_delivery_api
    FakeDeliveryAPI.instance
  end
end
