require 'spec_helper'
require 'models/valid_against_schema'

RSpec.describe DfidResearchOutput do
  let(:payload) { FactoryGirl.create(:dfid_research_output) }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"

  subject(:output) { DfidResearchOutput.new }

  it 'is always bulk published to hide the publishing-api published date' do
    expect(output.bulk_published).to be true
  end
end
