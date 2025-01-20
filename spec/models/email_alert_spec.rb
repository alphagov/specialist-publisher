require "spec_helper"

RSpec.describe "EmailAlert" do
  describe "#from_finder_schema" do
    it "builds an email alert for a finder schema with alerts configured for all content" do
      schema = FinderSchema.new
      schema.signup_content_id = "123"
      schema.subscription_list_title_prefix = "Finder email subscription"
      email_alert = EmailAlert.from_finder_schema(schema)
      expect(email_alert.type).to eq(:all_content)
      expect(email_alert.content_id).to eq(schema.signup_content_id)
      expect(email_alert.list_title_prefix).to eq(schema.subscription_list_title_prefix)
    end

    it "builds an email alert for a finder schema with alerts configured for a filtered set of the content" do
      schema = FinderSchema.new
      schema.signup_content_id = "123"
      schema.email_filter_options = { "email_filter_by" => "some_facet" }
      schema.subscription_list_title_prefix = "Finder email subscription"
      email_alert = EmailAlert.from_finder_schema(schema)
      expect(email_alert.type).to eq(:filtered_content)
      expect(email_alert.content_id).to eq(schema.signup_content_id)
      expect(email_alert.list_title_prefix).to eq(schema.subscription_list_title_prefix)
      expect(email_alert.filter).to eq("some_facet")
    end

    it "builds an email alert for a finder schema with alerts configured to use an external system" do
      schema = FinderSchema.new
      schema.signup_link = "https://example.com"
      email_alert = EmailAlert.from_finder_schema(schema)
      expect(email_alert.type).to eq(:external)
      expect(email_alert.link).to eq(schema.signup_link)
    end

    it "builds an email alert for a finder schema without alerts configured" do
      schema = FinderSchema.new
      email_alert = EmailAlert.from_finder_schema(schema)
      expect(email_alert.type).to eq(:no)
    end

    it "builds a list of possible values for email_filter_by" do
      schema = FinderSchema.new
      schema.facets = [
        { "key" => "foo" },
        { "key" => "bar" },
      ]
      email_alert = EmailAlert.from_finder_schema(schema)
      expect(email_alert.email_filter_by_candidates).to eq(%w[
        all_selected_facets
        foo
        bar
      ])
    end
  end

  describe "#from_finder_admin_form_params" do
    context "building an email alert for a finder schema with alerts configured for all content" do
      let(:email_alert_type) { "all_content" }

      it "sets type as all_content" do
        params = {
          "email_alert_type" => email_alert_type,
        }
        email_alert = EmailAlert.from_finder_admin_form_params(params)
        expect(email_alert.type).to eq(:all_content)
      end

      it "uses the all_content prefixed parameters" do
        params = {
          "email_alert_type" => email_alert_type,
          "all_content_signup_id" => "123",
          "all_content_list_title_prefix" => "Finder email subscription",
          "filtered_content_signup_id" => "456",
          "filtered_content_list_title_prefix" => "Something else",
        }
        email_alert = EmailAlert.from_finder_admin_form_params(params)
        expect(email_alert.content_id).to eq(params["all_content_signup_id"])
        expect(email_alert.list_title_prefix).to eq(params["all_content_list_title_prefix"])
      end

      it "deletes any existing `email_filter_options.email_filter_by` option" do
        params = {
          "email_alert_type" => email_alert_type,
          "all_content_email_filter_options" => {
            email_filter_by: "some_facet",
          }.to_json,
        }
        email_alert = EmailAlert.from_finder_admin_form_params(params)
        expect(email_alert.email_filter_options).to eq({})
      end

      it "converts a blank `email_filter_options` parameter into nil" do
        params = {
          "email_alert_type" => email_alert_type,
          "all_content_email_filter_options" => "",
        }
        email_alert = EmailAlert.from_finder_admin_form_params(params)
        expect(email_alert.email_filter_options).to eq(nil)
      end

      it "deletes any existing `email_filter_options.pre_checked_email_alert_checkboxes` option" do
        params = {
          "email_alert_type" => email_alert_type,
          "all_content_email_filter_options" => {
            pre_checked_email_alert_checkboxes: %w[foo bar baz],
          }.to_json,
        }
        email_alert = EmailAlert.from_finder_admin_form_params(params)
        expect(email_alert.email_filter_options).to eq({})
      end

      it "deletes any existing `signup_link` property" do
        params = {
          "email_alert_type" => email_alert_type,
          "signup_link" => "https://example.com",
        }
        email_alert = EmailAlert.from_finder_admin_form_params(params)
        expect(email_alert.link).to eq(nil)
      end

      it "retains any existing `email_filter_options.downcase_email_alert_topic_names` option" do
        params = {
          "email_alert_type" => email_alert_type,
          "all_content_email_filter_options" => {
            downcase_email_alert_topic_names: true,
          }.to_json,
        }
        email_alert = EmailAlert.from_finder_admin_form_params(params)
        expect(email_alert.email_filter_options).to eq({ "downcase_email_alert_topic_names" => true })
      end

      it "retains any existing `email_filter_options.email_alert_topic_name_overrides` option" do
        email_alert_topic_name_overrides = {
          "some_facet" => [
            {
              "facet_option_key" => "baz-baz",
              "topic_name_override" => "something ENTIRELY different",
            },
          ],
        }

        params = {
          "email_alert_type" => email_alert_type,
          "all_content_email_filter_options" => {
            email_alert_topic_name_overrides:,
          }.to_json,
        }
        email_alert = EmailAlert.from_finder_admin_form_params(params)
        expect(email_alert.email_filter_options).to eq({ "email_alert_topic_name_overrides" => email_alert_topic_name_overrides })
      end
    end

    context "building an email alert for a finder schema with alerts configured for a filtered set of content" do
      let(:email_alert_type) { "filtered_content" }

      it "sets type as filtered_content" do
        params = {
          "email_alert_type" => email_alert_type,
        }
        email_alert = EmailAlert.from_finder_admin_form_params(params)
        expect(email_alert.type).to eq(:filtered_content)
      end

      it "deletes any existing `signup_link` property" do
        params = {
          "email_alert_type" => email_alert_type,
          "signup_link" => "https://example.com",
          "email_filter_by" => "some_facet",
        }
        email_alert = EmailAlert.from_finder_admin_form_params(params)
        expect(email_alert.link).to eq(nil)
      end

      it "populates email_filter_options with the email_filter_by param" do
        params = {
          "email_alert_type" => email_alert_type,
          "email_filter_by" => "some_facet",
        }
        email_alert = EmailAlert.from_finder_admin_form_params(params)
        expect(email_alert.email_filter_options).to eq({
          "email_filter_by" => "some_facet",
        })
      end

      it "uses the filtered_content prefixed parameters" do
        params = {
          "email_alert_type" => email_alert_type,
          "all_content_signup_id" => "123",
          "all_content_list_title_prefix" => "Finder email subscription",
          "filtered_content_signup_id" => "456",
          "filtered_content_list_title_prefix" => "Something else",
        }
        email_alert = EmailAlert.from_finder_admin_form_params(params)
        expect(email_alert.content_id).to eq(params["filtered_content_signup_id"])
        expect(email_alert.list_title_prefix).to eq(params["filtered_content_list_title_prefix"])
      end

      it "retains any existing `email_filter_options.pre_checked_email_alert_checkboxes` option" do
        params = {
          "email_alert_type" => email_alert_type,
          "email_filter_by" => "some_facet",
          "filtered_content_email_filter_options" => {
            pre_checked_email_alert_checkboxes: %w[foo bar baz],
          }.to_json,
        }
        email_alert = EmailAlert.from_finder_admin_form_params(params)
        expect(email_alert.email_filter_options).to eq({
          "email_filter_by" => "some_facet",
          "pre_checked_email_alert_checkboxes" => %w[foo bar baz],
        })
      end

      it "copes with a blank `filtered_content_email_filter_options` value" do
        params = {
          "email_alert_type" => email_alert_type,
          "email_filter_by" => "some_facet",
          "filtered_content_email_filter_options" => "",
        }
        email_alert = EmailAlert.from_finder_admin_form_params(params)
        expect(email_alert.email_filter_options).to eq({
          "email_filter_by" => "some_facet",
        })
      end

      it "copes with no `filtered_content_email_filter_options` value" do
        params = {
          "email_alert_type" => email_alert_type,
          "email_filter_by" => "some_facet",
        }
        email_alert = EmailAlert.from_finder_admin_form_params(params)
        expect(email_alert.email_filter_options).to eq({
          "email_filter_by" => "some_facet",
        })
      end

      it "retains any existing `email_filter_options.downcase_email_alert_topic_names` option" do
        params = {
          "email_alert_type" => email_alert_type,
          "email_filter_by" => "some_facet",
          "filtered_content_email_filter_options" => {
            downcase_email_alert_topic_names: true,
          }.to_json,
        }
        email_alert = EmailAlert.from_finder_admin_form_params(params)
        expect(email_alert.email_filter_options).to eq({
          "email_filter_by" => "some_facet",
          "downcase_email_alert_topic_names" => true,
        })
      end

      it "retains any existing `email_filter_options.email_alert_topic_name_overrides` option" do
        email_alert_topic_name_overrides = {
          "some_facet" => [
            {
              "facet_option_key" => "baz-baz",
              "topic_name_override" => "something ENTIRELY different",
            },
          ],
        }
        params = {
          "email_alert_type" => email_alert_type,
          "email_filter_by" => "some_facet",
          "filtered_content_email_filter_options" => {
            email_alert_topic_name_overrides:,
          }.to_json,
        }
        email_alert = EmailAlert.from_finder_admin_form_params(params)
        expect(email_alert.email_filter_options).to eq({
          "email_filter_by" => "some_facet",
          "email_alert_topic_name_overrides" => email_alert_topic_name_overrides,
        })
      end
    end

    context "building an email alert for a finder schema with alerts configured to use an external system" do
      let(:email_alert_type) { "external" }

      it "populates signup_link" do
        params = {
          "email_alert_type" => email_alert_type,
          "signup_link" => "https://example.com",
        }
        email_alert = EmailAlert.from_finder_admin_form_params(params)
        expect(email_alert.type).to eq(:external)
        expect(email_alert.link).to eq(params["signup_link"])
      end

      it "drops all other email-related properties" do
        params = {
          "email_alert_type" => email_alert_type,
          "signup_link" => "https://example.com",
          "email_filter_by" => "some_facet",
          "all_content_signup_id" => "123",
          "all_content_list_title_prefix" => "Finder email subscription",
          "filtered_content_signup_id" => "456",
          "filtered_content_list_title_prefix" => "Something else",
          "all_content_email_filter_options" => {
            "foo" => "bar",
          }.to_json,
          "filtered_content_email_filter_options" => {
            "foo" => "bar",
          }.to_json,
        }
        email_alert = EmailAlert.from_finder_admin_form_params(params)
        expect(email_alert.email_filter_options).to eq(nil)
        expect(email_alert.content_id).to eq(nil)
        expect(email_alert.list_title_prefix).to eq(nil)
      end
    end

    context "building an email alert for a finder schema without alerts configured" do
      let(:email_alert_type) { "no" }

      it "builds an email alert for a finder schema without alerts configured" do
        params = {
          "email_alert_type" => email_alert_type,
        }
        email_alert = EmailAlert.from_finder_admin_form_params(params)
        expect(email_alert.type).to eq(:no)
      end

      it "drops all other email-related properties" do
        params = {
          "email_alert_type" => email_alert_type,
          "signup_link" => "https://example.com",
          "email_filter_by" => "some_facet",
          "all_content_signup_id" => "123",
          "all_content_list_title_prefix" => "Finder email subscription",
          "filtered_content_signup_id" => "456",
          "filtered_content_list_title_prefix" => "Something else",
          "all_content_email_filter_options" => {
            "foo" => "bar",
          }.to_json,
          "filtered_content_email_filter_options" => {
            "foo" => "bar",
          }.to_json,
        }
        email_alert = EmailAlert.from_finder_admin_form_params(params)
        expect(email_alert.email_filter_options).to eq(nil)
        expect(email_alert.content_id).to eq(nil)
        expect(email_alert.list_title_prefix).to eq(nil)
        expect(email_alert.link).to eq(nil)
      end
    end
  end

  describe "#to_finder_schema_attributes" do
    it "transforms the attributes of the email alert to a hash of finder schema attributes" do
      email_alert = EmailAlert.new
      email_alert.content_id = "123"
      email_alert.list_title_prefix = "Finder email subscription"
      email_alert.email_filter_options = { "email_filter_by" => "some_facet" }
      email_alert.link = "https://example.com"
      expect(email_alert.to_finder_schema_attributes).to eq({
        signup_content_id: "123",
        subscription_list_title_prefix: "Finder email subscription",
        email_filter_options: {
          "email_filter_by" => "some_facet",
        },
        signup_link: "https://example.com",
      })
    end

    it "converts falsey values to nil" do
      email_alert = EmailAlert.new
      email_alert.content_id = ""
      email_alert.link = ""
      expect(email_alert.to_finder_schema_attributes[:signup_content_id]).to eq(nil)
      expect(email_alert.to_finder_schema_attributes[:signup_link]).to eq(nil)
    end
  end
end
