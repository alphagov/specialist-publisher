require 'spec_helper'
require 'models/valid_against_schema'

RSpec.describe BusinessFinanceSupportScheme do
  let(:payload) { FactoryGirl.create(:business_finance_support_scheme) }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"
end
