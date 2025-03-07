require "spec_helper"
require "models/valid_against_schema"

EXCEPTIONS_TO_GENERAL_TESTING = %w[
  ai_assurance_portfolio_technique
  european_structural_investment_fund
].freeze

Dir["lib/documents/schemas/*.json"].each do |file|
  schema = JSON.parse(File.read(file))
  format = schema["filter"]["format"]

  next if EXCEPTIONS_TO_GENERAL_TESTING.include?(format)

  RSpec.describe format.classify.constantize do
    let(:payload) { FactoryBot.create(format.to_sym) }
    include_examples "it saves payloads that are valid against the 'specialist_document' schema"

    it "is not exportable" do
      unless subject.instance_of?(BusinessFinanceSupportScheme)
        expect(subject.class).not_to be_exportable
      end
    end
  end
end
