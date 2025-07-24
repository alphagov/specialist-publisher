require "rails_helper"

RSpec.describe "bulk_import_documents_from_csv", type: :task do
    let(:task) { Rake::Task["bulk_import_documents_from_csv"] }
    before(:each) { task.reenable }

    it "imports documents from a CSV file" do
      task.invoke
    end
end
