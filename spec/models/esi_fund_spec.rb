require 'spec_helper'
require 'models/valid_against_schema'

RSpec.describe EsiFund do
  let(:payload) { Payloads.esi_fund_content_item }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"
end
