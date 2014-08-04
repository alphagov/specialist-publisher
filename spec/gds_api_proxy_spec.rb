require "fast_spec_helper"

require "gds_api_proxy"

module GdsApi
  class BaseError < StandardError; end
end

RSpec.describe GdsApiProxy do
  subject(:api_proxy) {
    GdsApiProxy.new(gds_api)
  }

  let(:gds_api) {
    double(
      :gds_api,
      put_a_thing: response,
    )
  }

  let(:response) { double(:response) }
  let(:success_spy) { double(:success_spy, call: "not nil") }
  let(:error_spy) { double(:error_spy, call: "not nil") }

  describe "calling an api method" do
    let(:id_of_thing) { double(:id_of_thing) }
    let(:attributes_of_thing) { { foo: "bar" } }

    it "delegates to the GDS API object" do
      api_proxy.put_a_thing(
        id_of_thing,
        attributes_of_thing,
      )

      expect(gds_api).to have_received(:put_a_thing)
        .with(id_of_thing, attributes_of_thing)
    end

    it "returns a repsonse proxy" do
      expect(
        api_proxy.put_a_thing(
          id_of_thing,
          attributes_of_thing,
        )
      ).to be_a(GdsApiProxy::ResponseProxy)
    end

    context "when the request is successful" do
      it "calls the success callback with the response" do
        api_proxy.put_a_thing(
          id_of_thing,
          attributes_of_thing,
        )
        .on_success { |*args| success_spy.call(*args) }
        .on_error { |*args| error_spy.call(*args) }

        expect(success_spy).to have_received(:call).with(response)
      end

      it "does not call the error callback" do
        api_proxy.put_a_thing(
          id_of_thing,
          attributes_of_thing,
        )
        .on_success { |*args| success_spy.call(*args) }
        .on_error { |*args| error_spy.call(*args) }

        expect(error_spy).not_to have_received(:call)
      end
    end

    context "when an error is raised" do
      let(:error) { GdsApi::BaseError.new("Wat?") }

      before do
        allow(gds_api).to receive(:put_a_thing).and_raise(error)
      end

      it "calls the error callback with the exception and api arguments" do
        api_proxy.put_a_thing(
          id_of_thing,
          attributes_of_thing,
        )
        .on_success { |*args| success_spy.call(*args) }
        .on_error { |*args| error_spy.call(*args) }

        expect(error_spy).to have_received(:call)
          .with(error, id_of_thing, attributes_of_thing)
      end

      it "does not call the success callback" do
        api_proxy.put_a_thing(
          id_of_thing,
          attributes_of_thing,
        )
        .on_success { |*args| success_spy.call(*args) }
        .on_error { |*args| error_spy.call(*args) }

        expect(success_spy).not_to have_received(:call)
      end
    end
  end

  context "when the api does not respond to the message" do
    it "does not delegate" do
      expect {
        api_proxy.definitely_not_an_api_method
      }.to raise_error(NoMethodError)
    end
  end
end
