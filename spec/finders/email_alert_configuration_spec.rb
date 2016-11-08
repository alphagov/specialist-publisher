require 'spec_helper'

RSpec.describe "Email alert configuration" do
  all_finders = Dir["lib/documents/schemas/*.yml"].map do |filename|
    YAML.load_file(filename)
  end

  all_finders.each do |finder|
    describe "Finder configuration for #{finder['name']}" do
      next unless finder["email_filter_by"]

      it "only allows people to sign up to alerts that exist" do
        facet_used_to_email_things = finder["facets"].find do |facet|
          facet["key"] == finder["email_filter_by"]
        end

        actually_possible_keys_for_which_emails_will_be_sent = facet_used_to_email_things["allowed_values"].map do |allowed_value|
          allowed_value["value"]
        end

        finder["email_signup_choice"].each do |choice|
          expect(choice["key"]).to be_in(actually_possible_keys_for_which_emails_will_be_sent)
        end
      end
    end
  end
end
