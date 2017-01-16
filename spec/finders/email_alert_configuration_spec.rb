require 'spec_helper'

RSpec.describe "Email alert configuration" do
  all_finders = Dir["lib/documents/schemas/*.json"].map do |filename|
    JSON.parse(File.read(filename))
  end

  all_finders.each do |finder|
    describe "Finder configuration for #{finder['name']}" do
      next unless finder["email_filter_by"]

      before do
        @facet_used_to_email_things = finder["facets"].find do |facet|
          facet["key"] == finder["email_filter_by"]
        end
      end

      it "only allows people to sign up to alerts that exist" do
        actually_possible_keys_for_which_emails_will_be_sent = @facet_used_to_email_things["allowed_values"].map do |allowed_value|
          allowed_value["value"]
        end

        finder["email_signup_choice"].each do |choice|
          expect(choice["key"]).to be_in(actually_possible_keys_for_which_emails_will_be_sent)
        end
      end

      # This is a GovDelivery maximum limit
      # finder-frontend detects generated strings that are too long and
      # changes them, but this assumes that the combination of the prefix
      # and suffix does not already breach the limit, which we test here
      it "doesn't have a combined prefix and suffix longer than 255 characters" do
        next unless finder["subscription_list_title_prefix"] &&
            finder["subscription_list_title_prefix"]["many"] &&
            finder["email_filter_name"] &&
            finder["email_filter_name"]["plural"]

        short_name = finder["subscription_list_title_prefix"]["many"] +
          @facet_used_to_email_things["allowed_values"].length.to_s + " " +
          finder["email_filter_name"]["plural"]

        expect(short_name.length).to be <= 255
      end
    end
  end
end
