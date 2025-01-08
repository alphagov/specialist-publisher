require "spec_helper"

RSpec.describe FinderSignupContentItemPresenter do
  describe "#to_json" do
    Dir["lib/documents/schemas/*.json"].each do |file|
      let(:read_file) { File.read(file) }
      let(:payload) { JSON.parse(read_file) }

      it "is valid against the #{file} content schemas" do
        if payload.key?("email_filter_options")
          finder_signup_content_presenter = FinderSignupContentItemPresenter.new(payload, File.mtime(file))
          presented_data = finder_signup_content_presenter.to_json

          expect(presented_data[:schema_name]).to eq("finder_email_signup")
          expect(presented_data).to be_valid_against_publisher_schema("finder_email_signup")
        end
      end

      # email-alert-api limits the name of a subscription list to 1000 characters
      # We test here to make sure we don't try to create lists with names longer than this
      it "doesn't have a name longer than 1000 characters" do
        finder_signup_content_presenter = FinderSignupContentItemPresenter.new(payload, File.mtime(file))
        presented_data = finder_signup_content_presenter.to_json
        next unless presented_data[:details][:subscription_list_title_prefix]

        name = if presented_data[:details][:subscription_list_title_prefix][:plural]
                 # If the list name has singular and plural forms, test the plural
                 # form with every possible topic name appended to make the longest
                 # possible name
                 (presented_data[:details][:subscription_list_title_prefix][:plural] +
                   presented_data[:details][:email_filter_facets][0][:facet_choices].collect { |topic| topic[:topic_name] }.to_sentence)
                   .humanize
               else
                 # If the list name only has one form, then topic names are not
                 # appended; just check the name itself isn't too long
                 presented_data[:details][:subscription_list_title_prefix]
               end

        expect(name.length).to be <= 1000
      end
    end
  end

  describe ".content_id" do
    it "returns the signup_content_id" do
      schema = { "email_filter_options" => { "signup_content_id" => "abc123" } }
      expect(FinderSignupContentItemPresenter.new(schema).content_id).to eq("abc123")
    end
  end

  describe ".subscription_list_title_prefix" do
    it "returns an empty hash if not specified" do
      expect(FinderSignupContentItemPresenter.new({}).subscription_list_title_prefix).to eq({})
    end

    it "returns a string if specified" do
      schema = { "email_filter_options" => { "subscription_list_title_prefix" => "foo" } }
      expect(FinderSignupContentItemPresenter.new(schema).subscription_list_title_prefix).to eq("foo")
    end

    it "returns a hash if specified" do
      hash = { "singular" => "foo", "plural" => "bar" }
      schema = { "email_filter_options" => { "subscription_list_title_prefix" => hash } }
      expect(FinderSignupContentItemPresenter.new(schema).subscription_list_title_prefix).to eq(hash)
    end
  end

  describe ".email_filter_facets" do
    let(:facet_one) do
      {
        "key": "life_saving_maritime_appliance_service_station_regions",
        "name": "Regions in the UK",
        "short_name": "region",
        "type": "text",
        "preposition": "in region",
        "display_as_result_metadata": true,
        "filterable": true,
        "allowed_values": [
          {
            "label": "Foo",
            "value": "foo",
          },
          {
            "label": "Bar",
            "value": "bar",
          },
        ],
      }
    end
    let(:facet_two) do
      {
        "key": "some_other_facet",
        "name": "Some other facet",
        "filterable": true,
        "allowed_values": [
          {
            "label": "Baz",
            "value": "baz-baz",
          },
          {
            "label": "Something",
            "value": "bla",
          },
        ],
      }
    end
    let(:facet_with_no_allowed_values) do
      {
        "key": "some_date",
        "name": "Some date",
        "filterable": true,
        "type": "date",
      }
    end
    let(:facet_with_filterable_false) do
      {
        "key": "some_options",
        "name": "Some options",
        "filterable": false,
        "allowed_values": [
          {
            "label": "some value",
            "value": "val",
          },
        ],
      }
    end
    let(:schema) do
      {
        "facets" => JSON.parse([facet_one, facet_two, facet_with_no_allowed_values, facet_with_filterable_false].to_json),
      }
    end

    it "returns an empty array if no email_filter_by is provided" do
      expect(FinderSignupContentItemPresenter.new(schema).email_filter_facets).to eq([])
    end

    it "returns all filterable facets with allowed_values, if 'all_selected_facets' is passed" do
      schema.merge!({
        "email_filter_options" => {
          "email_filter_by" => "all_selected_facets",
        },
      })
      expect(FinderSignupContentItemPresenter.new(schema).email_filter_facets).to eq(
        [
          {
            facet_id: "life_saving_maritime_appliance_service_station_regions",
            facet_name: "Regions in the UK",
            facet_choices: [
              {
                key: "foo",
                prechecked: false,
                radio_button_name: "Foo",
                topic_name: "Foo",
              },
              {
                key: "bar",
                prechecked: false,
                radio_button_name: "Bar",
                topic_name: "Bar",
              },
            ],
          },
          {
            facet_id: "some_other_facet",
            facet_name: "Some other facet",
            facet_choices: [
              {
                key: "baz-baz",
                prechecked: false,
                radio_button_name: "Baz",
                topic_name: "Baz",
              },
              {
                key: "bla",
                prechecked: false,
                radio_button_name: "Something",
                topic_name: "Something",
              },
            ],
          },
        ],
      )
    end

    it "returns all filterable facets with allowed_values (if 'all_selected_facets' is passed), minus any specified in 'all_selected_facets_except_for'" do
      schema.merge!({
        "email_filter_options" => {
          "email_filter_by" => "all_selected_facets",
          "all_selected_facets_except_for" => %w[life_saving_maritime_appliance_service_station_regions],
        },
      })
      expect(FinderSignupContentItemPresenter.new(schema).email_filter_facets).to eq(
        [
          {
            facet_id: "some_other_facet",
            facet_name: "Some other facet",
            facet_choices: [
              {
                key: "baz-baz",
                prechecked: false,
                radio_button_name: "Baz",
                topic_name: "Baz",
              },
              {
                key: "bla",
                prechecked: false,
                radio_button_name: "Something",
                topic_name: "Something",
              },
            ],
          },
        ],
      )
    end

    it "returns the filterable facet corresponding to 'email_filter_by'" do
      schema.merge!({
        "email_filter_options" => {
          "email_filter_by" => "some_other_facet",
        },
      })
      expect(FinderSignupContentItemPresenter.new(schema).email_filter_facets).to eq(
        [
          {
            facet_id: "some_other_facet",
            facet_name: "Some other facet",
            required: true,
            facet_choices: [
              {
                key: "baz-baz",
                prechecked: false,
                radio_button_name: "Baz",
                topic_name: "Baz",
              },
              {
                key: "bla",
                prechecked: false,
                radio_button_name: "Something",
                topic_name: "Something",
              },
            ],
          },
        ],
      )
    end

    it "downcases the generated topic name if downcase_email_alert_topic_names passed" do
      schema.merge!({
        "email_filter_options" => {
          "email_filter_by" => "some_other_facet",
          "downcase_email_alert_topic_names" => true,
        },
      })
      expect(FinderSignupContentItemPresenter.new(schema).email_filter_facets).to eq(
        [
          {
            facet_id: "some_other_facet",
            facet_name: "Some other facet",
            required: true,
            facet_choices: [
              {
                key: "baz-baz",
                prechecked: false,
                radio_button_name: "Baz",
                topic_name: "baz",
              },
              {
                key: "bla",
                prechecked: false,
                radio_button_name: "Something",
                topic_name: "something",
              },
            ],
          },
        ],
      )
    end

    it "overrides the generated topic name if email_alert_topic_name_overrides passed" do
      schema.merge!({
        "email_filter_options" => {
          "email_filter_by" => "some_other_facet",
          "email_alert_topic_name_overrides" => {
            "baz-baz" => "something ENTIRELY different",
          },
        },
      })
      expect(FinderSignupContentItemPresenter.new(schema).email_filter_facets).to eq(
        [
          {
            facet_id: "some_other_facet",
            facet_name: "Some other facet",
            required: true,
            facet_choices: [
              {
                key: "baz-baz",
                prechecked: false,
                radio_button_name: "Baz",
                topic_name: "something ENTIRELY different",
              },
              {
                key: "bla",
                prechecked: false,
                radio_button_name: "Something",
                topic_name: "Something",
              },
            ],
          },
        ],
      )
    end

    it "pre-checks any items specified in the pre_checked_email_alert_checkboxes array" do
      schema.merge!({
        "email_filter_options" => {
          "email_filter_by" => "some_other_facet",
          "pre_checked_email_alert_checkboxes" => %w[baz-baz],
        },
      })
      expect(FinderSignupContentItemPresenter.new(schema).email_filter_facets).to eq(
        [
          {
            facet_id: "some_other_facet",
            facet_name: "Some other facet",
            required: true,
            facet_choices: [
              {
                key: "baz-baz",
                prechecked: true,
                radio_button_name: "Baz",
                topic_name: "Baz",
              },
              {
                key: "bla",
                prechecked: false,
                radio_button_name: "Something",
                topic_name: "Something",
              },
            ],
          },
        ],
      )
    end
  end
end
