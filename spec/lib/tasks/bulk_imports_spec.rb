require "rails_helper"

RSpec.describe "rake bulk_imports", type: :task do
  before { Rake::Task["bulk_imports:protected_food_and_drink_names"].reenable }

  context "bulk_imports:protected_food_and_drink_names" do
    let(:csv_file) { Rails.root.join("spec/support/csvs/spirits_for_import.csv") }

    before do
      stub_request(:patch, /http:\/\/publishing-api.dev.gov.uk\/v2.*/).to_return(status: 200, body: "", headers: {})
      stub_request(:put, /http:\/\/publishing-api.dev.gov.uk\/v2.*/).to_return(status: 200, body: "", headers: {})
    end

    it "imports protected food and drink names data from a file" do
      expect { Rake::Task["bulk_imports:protected_food_and_drink_names"].invoke(csv_file) }.to \
        output("No errors reported. 8 records imported.\n").to_stdout
    end

    context "with invalid data" do
      let(:csv_file) { Rails.root.join("spec/support/csvs/spirits_for_import_broken.csv") }

      it "reports any data it could not import and the error preventing it from saving" do
        expected_output = "ERROR - Document index: 1. Registered name: . Title can't be blank. Registered name can't be blank\n" \
          "ERROR - Document index: 2. Registered name: Irish Poteen/Irish Poitín. Status can't be blank\n" \
          "ERROR - Document index: 3. Registered name: Irish Whiskey/Uisce Beatha Eireannach/Irish Whisky. Country of origin can't be blank\n" \
          "ERROR - Document index: 6. Registered name: Tennessee whisky (Also spelled as “Tennessee whiskey”). Register can't be blank\n" \
          "4 out of 8 records imported. 4 errors reported\n"

        expect { Rake::Task["bulk_imports:protected_food_and_drink_names"].invoke(csv_file) }.to \
          output(expected_output).to_stdout
      end
    end
  end
end
