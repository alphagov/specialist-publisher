require "rails_helper"

RSpec.describe OrganisationsHelper, type: :helper do
  describe "#organisation_options_for_design_system" do
    it "returns a sorted list of organisation hashes with the correct selected organisation and an 'all' option" do
      organisations = []
      5.times do |n|
        organisations.push(Organisation.new("title" => "Organisation #{n}", "content_id" => SecureRandom.uuid))
      end
      expect(Organisation).to receive(:all).and_return(organisations.shuffle)
      selected_organisation = organisations.first

      result = organisation_options_for_design_system(selected_organisation.content_id)
      expected_result = [
        {
          text: "All organisations",
          value: "all",
          selected: false,
        },
      ] + organisations.map do |organisation|
        {
          text: organisation.title,
          value: organisation.content_id,
          selected: selected_organisation.content_id == organisation.content_id,
        }
      end
      expect(result).to eq(expected_result)
    end
  end
end
