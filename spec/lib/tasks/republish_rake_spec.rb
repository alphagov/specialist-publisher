require 'rails_helper'
require 'rake'
load File.join(Rails.root, 'Rakefile')
load File.join(Rails.root, 'lib/tasks/republish.rake')

RSpec.describe 'Republish rake task' do
  describe 'republish:all_documents_to_rummager' do
    it 'invokes RummagerRepublisher' do
      allow(RummagerRepublisher).to receive(:republish_all)

      Rake::Task['republish:all_documents_to_rummager'].invoke
    end
  end
end
