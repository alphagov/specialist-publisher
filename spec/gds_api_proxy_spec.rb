require "fast_spec_helper"

require "gds_api_proxy"
require "gds_api/exceptions"

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
  let(:spy) { double(:spy) }

  def make_request(*args)
    api_proxy.put_a_thing(*args)
      .on_success { |*args| spy.success(*args) }
      .on_not_found { |*args| spy.not_found(*args) }
      .on_error { |*args| spy.error(*args) }
  end

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
        expect(spy).to receive(:success).with(response)

        make_request(id_of_thing, attributes_of_thing)
      end
    end

    context "when the response is not found" do
      let(:error) { GdsApi::HTTPNotFound.new(404, "resource-not-found") }

      before do
        allow(gds_api).to receive(:put_a_thing).and_raise(error)
      end

      it "calls the not_found callback with the api arguments" do
        expect(spy).to receive(:not_found).with(id_of_thing, attributes_of_thing)

        make_request(id_of_thing, attributes_of_thing)
      end
    end

    context "when an error is raised" do
      let(:error) { GdsApi::BaseError.new("Wat?") }

      before do
        allow(gds_api).to receive(:put_a_thing).and_raise(error)
      end

      it "calls the error callback with the exception and api arguments" do
        expect(spy).to receive(:error).with(error, id_of_thing, attributes_of_thing)

        make_request(id_of_thing, attributes_of_thing)
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
