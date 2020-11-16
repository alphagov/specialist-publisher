require "spec_helper"

RSpec.describe Services do
  describe ".with_timeout" do
    it "executes a block of code with the defined services timeout" do
      options = described_class.publishing_api.client.options

      # Set default timeout
      options[:timeout] = 1

      expect(options).to receive(:[]=).with(:timeout, 30).once.and_call_original.ordered
      expect(options).to receive(:[]=).with(:timeout, 1).once.and_call_original.ordered

      result = described_class.with_timeout(30) { 2 + 3 }

      expect(result).to eq(5)
    end
  end
end
