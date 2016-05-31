require 'spec_helper'
require 'models/valid_against_schema'

RSpec.describe CmaCase do
  let(:payload) { FactoryGirl.create(:cma_case) }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"
end
