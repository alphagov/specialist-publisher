require "spec_helper"

RSpec.describe "Facet" do
  describe "#from_finder_admin_form_params" do
    it "builds a facet for a finder schema" do
      params = {
        "key" => "foo",
        "name" => "Foo",
        "short_name" => "f",
        "type" => "text",
        "preposition" => "sector",
        "display_as_result_metadata" => "false",
        "filterable" => "true",
        "show_option_select_filter" => "true",
        "allowed_values" => "existing value {existing-value}\nnew value",
      }
      facet = Facet.from_finder_admin_form_params(params)
      expect(facet.key).to eq("foo")
      expect(facet.name).to eq("Foo")
      expect(facet.short_name).to eq("f")
      expect(facet.type).to eq("text")
      expect(facet.preposition).to eq("sector")
      expect(facet.display_as_result_metadata).to eq(false)
      expect(facet.filterable).to eq(true)
      expect(facet.show_option_select_filter).to eq(true)
    end

    it "derives the key from the name if no key provided" do
      params = { "name" => "Foo bar & baz" }
      facet = Facet.from_finder_admin_form_params(params)
      expect(facet.key).to eq("foo_bar_and_baz")
    end

    it "strips out any special characters" do
      params = { "name" => "O'Shaunnessey, Filley & Partners ©" }
      facet = Facet.from_finder_admin_form_params(params)
      expect(facet.key).to eq("oshaunnessey_filley_and_partners")
    end

    it "returns nil for 'short_name' if not provided/blank" do
      facet = Facet.from_finder_admin_form_params({ "short_name" => "" })
      expect(facet.short_name).to eq(nil)
    end

    it "returns nil for 'preposition' if not provided/blank" do
      facet = Facet.from_finder_admin_form_params({ "preposition" => "" })
      expect(facet.preposition).to eq(nil)
    end

    describe "inferring the boolean value, or absence of a value, for 'display_as_result_metadata', 'filterable', 'show_option_select_filter'" do
      it "converts 'true' to true for 'display_as_result_metadata'" do
        facet = Facet.from_finder_admin_form_params({ "display_as_result_metadata" => "true" })
        expect(facet.display_as_result_metadata).to eq(true)
      end

      it "converts 'false' to false for 'display_as_result_metadata'" do
        facet = Facet.from_finder_admin_form_params({ "display_as_result_metadata" => "false" })
        expect(facet.display_as_result_metadata).to eq(false)
      end

      it "sets 'display_as_result_metadata' to 'nil' for any other values" do
        facet = Facet.from_finder_admin_form_params({ "display_as_result_metadata" => "" })
        expect(facet.display_as_result_metadata).to eq(nil)
      end

      it "converts 'true' to true for 'filterable'" do
        facet = Facet.from_finder_admin_form_params({ "filterable" => "true" })
        expect(facet.filterable).to eq(true)
      end

      it "converts 'false' to false for 'filterable'" do
        facet = Facet.from_finder_admin_form_params({ "filterable" => "false" })
        expect(facet.filterable).to eq(false)
      end

      it "sets 'filterable' to 'nil' for any other values" do
        facet = Facet.from_finder_admin_form_params({ "filterable" => "" })
        expect(facet.filterable).to eq(nil)
      end

      it "converts 'true' to true for 'show_option_select_filter'" do
        facet = Facet.from_finder_admin_form_params({ "show_option_select_filter" => "true" })
        expect(facet.show_option_select_filter).to eq(true)
      end

      it "sets 'show_option_select_filter' to 'nil' if 'false' is passed" do
        facet = Facet.from_finder_admin_form_params({ "show_option_select_filter" => "false" })
        expect(facet.show_option_select_filter).to eq(nil)
      end
    end

    describe "constructing the allowed_values" do
      it "uses any pre-supplied keys in curly brackets" do
        params = { "type" => "enum_text_multiple", "allowed_values" => "Foo {food}\nBart {bar}" }
        facet = Facet.from_finder_admin_form_params(params)
        expect(facet.allowed_values).to eq([
          { label: "Foo", value: "food" },
          { label: "Bart", value: "bar" },
        ])
      end

      it "also works for the enum_text_single 'type'" do
        params = { "type" => "enum_text_single", "allowed_values" => "Foo {food}\nBart {bar}" }
        facet = Facet.from_finder_admin_form_params(params)
        expect(facet.allowed_values).to eq([
          { label: "Foo", value: "food" },
          { label: "Bart", value: "bar" },
        ])
      end

      it "also works for the 'nested_enum_text_single' type" do
        params = { "type" => "nested_enum_text_single", "allowed_values" => "Foo {food}\nBart {bar}" }
        facet = Facet.from_finder_admin_form_params(params)
        expect(facet.allowed_values).to eq([
          { label: "Foo", value: "food" },
          { label: "Bart", value: "bar" },
        ])
      end

      it "also works for the 'nested_enum_text_multiple' type" do
        params = { "type" => "nested_enum_text_multiple", "allowed_values" => "Foo {food}\nBart {bar}" }
        facet = Facet.from_finder_admin_form_params(params)
        expect(facet.allowed_values).to eq([
          { label: "Foo", value: "food" },
          { label: "Bart", value: "bar" },
        ])
      end

      it "derives the key, in kebab-case, from the label if no key provided" do
        params = { "type" => "enum_text_multiple", "allowed_values" => "Foo\nSome Long Name" }
        facet = Facet.from_finder_admin_form_params(params)
        expect(facet.allowed_values).to eq([
          { label: "Foo", value: "foo" },
          { label: "Some Long Name", value: "some-long-name" },
        ])
      end

      it "strips any extraneous spaces" do
        params = { "type" => "enum_text_multiple", "allowed_values" => "Foo     { bar  }" }
        facet = Facet.from_finder_admin_form_params(params)
        expect(facet.allowed_values).to eq([
          { label: "Foo", value: "bar" },
        ])
      end

      it "returns empty array if no values provided" do
        params = { "type" => "enum_text_multiple", "allowed_values" => "" }
        facet = Facet.from_finder_admin_form_params(params)
        expect(facet.allowed_values).to eq([])
      end

      it "returns nil if not of an enum type, even if allowed_values have been specified" do
        params = { "type" => "text", "allowed_values" => "foo {foo}\nbar" }
        facet = Facet.from_finder_admin_form_params(params)
        expect(facet.allowed_values).to eq(nil)

        params = { "type" => "date", "allowed_values" => "foo {foo}\nbar" }
        facet = Facet.from_finder_admin_form_params(params)
        expect(facet.allowed_values).to eq(nil)
      end

      it "truncates a value string if it's longer than 500 characters" do
        params = { "type" => "enum_text_multiple", "allowed_values" => "LL {#{'V' * 500}}" }
        facet = Facet.from_finder_admin_form_params(params)
        expect(facet.allowed_values).to eq([{ label: "LL", value: "V" * 496 }])
      end
    end

    describe "converting the facet 'type' and setting the corresponding specialist_publisher_properties" do
      it "converts 'enum_text_multiple' type to 'text', and sets specialist_publisher_properties to select multiple" do
        params = { "type" => "enum_text_multiple" }
        facet = Facet.from_finder_admin_form_params(params)
        expect(facet.type).to eq("text")
        expect(facet.specialist_publisher_properties).to eq({ select: "multiple" })
      end

      it "converts 'enum_text_single' type to 'text', and sets specialist_publisher_properties to select one" do
        params = { "type" => "enum_text_single" }
        facet = Facet.from_finder_admin_form_params(params)
        expect(facet.type).to eq("text")
        expect(facet.specialist_publisher_properties).to eq({ select: "one" })
      end

      it "leaves type 'text' as-is, and sets specialist_publisher_properties to nil" do
        params = { "type" => "text" }
        facet = Facet.from_finder_admin_form_params(params)
        expect(facet.type).to eq("text")
        expect(facet.specialist_publisher_properties).to eq(nil)
      end

      it "leaves type 'date' as-is, and sets specialist_publisher_properties to nil" do
        params = { "type" => "date" }
        facet = Facet.from_finder_admin_form_params(params)
        expect(facet.type).to eq("date")
        expect(facet.specialist_publisher_properties).to eq(nil)
      end

      it "adds presence validations to the specialist_publisher_properties if type is text" do
        params = { "type" => "enum_text_single", "validations" => %w[required] }
        facet = Facet.from_finder_admin_form_params(params)
        expect(facet.type).to eq("text")
        expect(facet.specialist_publisher_properties).to eq({ select: "one", validations: { required: {} } })
      end

      it "adds presence validations to the specialist_publisher_properties if type is date" do
        params = { "type" => "date", "validations" => %w[required] }
        facet = Facet.from_finder_admin_form_params(params)
        expect(facet.type).to eq("date")
        expect(facet.specialist_publisher_properties).to eq({ validations: { required: {} } })
      end
    end

    context "when the facet is nested" do
      it "builds a facet containing its sub-facet's data" do
        params = {
          "type" => "nested_enum_text_multiple",
          "sub_facet" => "Some sub facet name {some_sub_facet_key}",
          "allowed_values" => "existing value {existing-value}\n- new sub facet value",
        }
        facet = Facet.from_finder_admin_form_params(params)
        expect(facet.type).to eq("nested")
        expect(facet.sub_facet_key).to eq("some_sub_facet_key")
        expect(facet.sub_facet_name).to eq("Some sub facet name")
        expect(facet.allowed_values).to eq([{
          label: "existing value",
          value: "existing-value",
          sub_facets: [
            {
              label: "new sub facet value",
              value: "new-sub-facet-value",
            },
          ],
        }])
      end

      it "strips allowed values string, and respects dashes in labels" do
        params = {
          "type" => "enum_text_multiple",
          "sub_facet" => "Some sub facet name {some_sub_facet_key}",
          "allowed_values" => "existing value - with some - dashes in it {existing-value-with-some-dashes-in-it} \n\n - new sub facet value \n another main value\n\n - another sub facet value",
        }
        facet = Facet.from_finder_admin_form_params(params)
        expect(facet.allowed_values).to eq([
          {
            label: "existing value - with some - dashes in it",
            value: "existing-value-with-some-dashes-in-it",
            sub_facets: [
              {
                label: "new sub facet value",
                value: "new-sub-facet-value",
              },
            ],
          },
          {
            label: "another main value",
            value: "another-main-value",
            sub_facets: [
              {
                label: "another sub facet value",
                value: "another-sub-facet-value",
              },
            ],
          },
        ])
      end

      it "derives the keys for main and sub facets, in kebab-case, from the label if no key provided" do
        params = {
          "type" => "nested_enum_text_multiple",
          "sub_facet" => "Some sub facet name {some_sub_facet_key}",
          "allowed_values" => "Main Facet 1\n- Sub Facet 11\n- Sub Facet 12\nMain Facet 2\n- Sub Facet 21\n- Sub Facet 22\nMain Facet 3",
        }
        facet = Facet.from_finder_admin_form_params(params)
        expect(facet.type).to eq("nested")
        expect(facet.sub_facet_key).to eq("some_sub_facet_key")
        expect(facet.sub_facet_name).to eq("Some sub facet name")
        expect(facet.allowed_values).to eq([
          {
            label: "Main Facet 1",
            value: "main-facet-1",
            sub_facets: [
              {
                label: "Sub Facet 11",
                value: "sub-facet-11",
              },
              {
                label: "Sub Facet 12",
                value: "sub-facet-12",
              },
            ],
          },
          {
            label: "Main Facet 2",
            value: "main-facet-2",
            sub_facets: [
              {
                label: "Sub Facet 21",
                value: "sub-facet-21",
              },
              {
                label: "Sub Facet 22",
                value: "sub-facet-22",
              },
            ],
          },
          {
            label: "Main Facet 3",
            value: "main-facet-3",
          },
        ])
      end

      it "uses any pre-supplied keys in curly brackets, if provided" do
        params = {
          "type" => "nested_enum_text_single",
          "sub_facet" => "Some sub facet name {some_sub_facet_key}",
          "allowed_values" => "Main Facet 1{main-facet-1}\n- Sub Facet 11{sub-facet-11}\n- Sub Facet 12 NEW\nMain Facet 2{main-facet-2}\n- Sub Facet 21{sub-facet-21}\n- Sub Facet 22{sub-facet-22}\nMain Facet 3{main-facet-3}",
        }
        facet = Facet.from_finder_admin_form_params(params)
        expect(facet.type).to eq("nested")
        expect(facet.sub_facet_key).to eq("some_sub_facet_key")
        expect(facet.sub_facet_name).to eq("Some sub facet name")
        expect(facet.allowed_values).to eq([
          {
            label: "Main Facet 1",
            value: "main-facet-1",
            sub_facets: [
              {
                label: "Sub Facet 11",
                value: "sub-facet-11",
              },
              {
                label: "Sub Facet 12 NEW",
                value: "sub-facet-12-new",
              },
            ],
          },
          {
            label: "Main Facet 2",
            value: "main-facet-2",
            sub_facets: [
              {
                label: "Sub Facet 21",
                value: "sub-facet-21",
              },
              {
                label: "Sub Facet 22",
                value: "sub-facet-22",
              },
            ],
          },
          {
            label: "Main Facet 3",
            value: "main-facet-3",
          },
        ])
      end
    end
  end

  describe "#to_finder_schema_attributes" do
    it "transforms the attributes of the facet to a hash of finder schema attributes" do
      facet = Facet.new
      facet.key = "foo"
      facet.name = "Foo"
      facet.short_name = "f"
      facet.type = "nested"
      facet.preposition = "sector"
      facet.display_as_result_metadata = false
      facet.filterable = true
      facet.allowed_values = [
        { label: "existing value", value: "existing-value" },
        { label: "new value", value: "new-value" },
      ]
      facet.show_option_select_filter = true
      facet.specialist_publisher_properties = { select: "one" }

      expect(facet.to_finder_schema_attributes).to eq({
        key: "foo",
        name: "Foo",
        short_name: "f",
        type: "nested",
        preposition: "sector",
        display_as_result_metadata: false,
        filterable: true,
        allowed_values: [
          { label: "existing value", value: "existing-value" },
          { label: "new value", value: "new-value" },
        ],
        show_option_select_filter: true,
        specialist_publisher_properties: { select: "one" },
      })
    end

    it "omits any nil values from the hash" do
      facet = Facet.new
      facet.key = "foo"
      facet.name = "Foo"
      facet.type = "text"

      expect(facet.to_finder_schema_attributes).to eq({
        key: "foo",
        name: "Foo",
        type: "text",
      })
    end

    it "returns the hash keys in a specific order (to minimise the eventual diff)" do
      facet = Facet.new
      facet.key = "foo"
      facet.name = "Foo"
      facet.short_name = "f"
      facet.type = "text"
      facet.preposition = "sector"
      facet.display_as_result_metadata = false
      facet.filterable = true
      facet.allowed_values = [
        { label: "existing value", value: "existing-value" },
        { label: "new value", value: "new-value" },
      ]
      facet.specialist_publisher_properties = { select: "one" }

      expect(facet.to_finder_schema_attributes.keys).to eq(%i[
        allowed_values
        display_as_result_metadata
        filterable
        key
        name
        preposition
        short_name
        specialist_publisher_properties
        type
      ])
    end
  end
end
