require 'spec_helper'
require 'models/valid_against_schema'

RSpec.describe AaibReport do
  let(:payload) { Payloads.aaib_report_content_item }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"
end
