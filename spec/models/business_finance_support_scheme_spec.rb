require 'spec_helper'
require 'models/valid_against_schema'

RSpec.describe BusinessFinanceSupportScheme do
  let(:payload) { FactoryGirl.create(:business_finance_support_scheme) }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"

  it 'is exportable' do
    expect(described_class).to be_exportable
  end
end
