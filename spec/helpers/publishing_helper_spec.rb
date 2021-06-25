require "rails_helper"

RSpec.describe PublishingHelper, type: :helper do
  let(:document_class) { Class.new { include ActiveModel::Validations } }
  let(:document) { document_class.new }
  let(:http_error) { GdsApi::HTTPErrorResponse.new(422, "boom!") }

  describe "#handle_remote_error" do
    it "calls the given block" do
      expect(document).to receive(:publish!).once

      handled = handle_remote_error(document) do
        document.publish!
      end

      expect(handled).to be true
    end

    it "rescues GdsApi::HTTPErrorResponse exceptions" do
      allow(document).to receive(:explode!).and_raise(http_error)
      expect(GovukError).to receive(:notify).with(http_error)

      handled = handle_remote_error(document) do
        document.explode!
      end

      expect(handled).to be false
    end
  end

  describe "#set_errors_on", type: :helper do
    it "assigns an object which can be used to store errors" do
      allow(document).to receive(:errors).and_return(ActiveModel::Errors.new(document))
      allow(document).to receive(:explode!).and_raise(http_error)
      expect(GovukError).to receive(:notify).with(http_error)

      handled = handle_remote_error(document) do
        set_errors_on(document)
        document.explode!
      end

      expect(document.errors[:base]).to eq(["boom!"])
      expect(handled).to be false
    end

    it "only assigns instances of ActiveModel" do
      expect { set_errors_on(double(:thing)) }.to raise_error(ArgumentError)
    end
  end
end
