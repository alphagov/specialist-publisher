require "spec_helper"

RSpec.describe "Email alert configuration" do
  all_finders = Dir["lib/documents/schemas/*.json"].map do |filename|
    JSON.parse(File.read(filename))
  end

  all_finders.each do |finder|
    next if finder["email_filter_by"] == "all_selected_facets"

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

        finder.dig("email_filter_facets", 0, "facet_choices").each do |choice|
          expect(choice["key"]).to be_in(actually_possible_keys_for_which_emails_will_be_sent)
        end
      end

      # email-alert-api limits the name of a subscription list to 1000 characters
      # We test here to make sure we don't try to create lists with names longer than this
      it "doesn't have a name longer than 1000 characters" do
        next unless finder["subscription_list_title_prefix"]

        name = if finder["subscription_list_title_prefix"]["plural"]
                 # If the list name has singular and plural forms, test the plural
                 # form with every possible topic name appended to make the longest
                 # possible name
                 (finder["subscription_list_title_prefix"]["plural"] +
                   finder.dig("email_filter_facets", 0, "facet_choices").collect { |topic| topic["topic_name"] }.to_sentence)
                   .humanize
               else
                 # If the list name only has one form, then topic names are not
                 # appended; just check the name itself isn't too long
                 finder["subscription_list_title_prefix"]
               end

        expect(name.length).to be <= 1000
      end
    end
  end
end
