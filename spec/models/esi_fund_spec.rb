require 'spec_helper'
require 'models/valid_against_schema'

RSpec.describe EsiFund do
  let(:payload) { FactoryGirl.create(:esi_fund) }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"
end
