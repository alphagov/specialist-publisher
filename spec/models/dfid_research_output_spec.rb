require 'spec_helper'

RSpec.describe DfidResearchOutput do
  subject(:output) { DfidResearchOutput.new }

  it 'is always bulk published to hide the publishing-api published date' do
    expect(output.bulk_published).to be true
  end
end
