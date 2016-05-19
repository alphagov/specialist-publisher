require 'spec_helper'
require 'models/valid_against_schema'

RSpec.describe CountrysideStewardshipGrant do
  let(:payload) { Payloads.countryside_stewardship_grant_content_item }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"
end
