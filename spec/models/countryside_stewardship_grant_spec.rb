require 'spec_helper'
require 'models/valid_against_schema'

RSpec.describe CountrysideStewardshipGrant do
  let(:payload) { FactoryGirl.create(:countryside_stewardship_grant) }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"
end
