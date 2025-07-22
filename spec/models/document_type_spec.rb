require "spec_helper"
require "models/valid_against_schema"

EXCEPTIONS_TO_GENERAL_TESTING = %w[
  ai_assurance_portfolio_technique
].freeze

Dir["lib/documents/schemas/*.json"].each do |file|
  format = File.basename(file, ".json").singularize

  next if EXCEPTIONS_TO_GENERAL_TESTING.include?(format)

  RSpec.describe format.classify.constantize do
    let(:payload) { FactoryBot.create(format.to_sym) }
    include_examples "it saves payloads that are valid against the 'specialist_document' schema"
  end
end
