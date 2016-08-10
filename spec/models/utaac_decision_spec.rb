require 'spec_helper'
require 'models/valid_against_schema'

RSpec.describe UtaacDecision do
  let(:payload) { FactoryGirl.create(:utaac_decisions) }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"
end
