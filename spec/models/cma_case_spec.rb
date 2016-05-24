require 'spec_helper'
require 'models/valid_against_schema'

RSpec.describe CmaCase do
  let(:payload) { Payloads.cma_case_content_item }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"
end
