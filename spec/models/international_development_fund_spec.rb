require 'spec_helper'
require 'models/valid_against_schema'

RSpec.describe InternationalDevelopmentFund do
  let(:payload) { FactoryGirl.create(:international_development_fund) }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"
end
