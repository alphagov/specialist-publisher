require "spec_helper"
require "manual"

def match_any_body
  lambda { |a| true }
end

RSpec.describe Section do
  let(:content_id) { SecureRandom.uuid }

  describe ".find" do
    let(:manual_content_id) { SecureRandom.uuid }
    let(:section) do
      described_class.new(content_id: content_id,
                          manual_content_id: manual_content_id)
    end

    before do
      expect(described_class).to receive(:from_publishing_api)
                                   .with(content_id: content_id)
                                   .and_return(section)
    end

    context "with content_id" do
      it "fetches the content item from the publishing api" do
        expect(described_class.find(content_id: content_id)).to eq(section)
      end
    end

    context "with content_id and manual_content_id" do
      it "fetches the content item and validates it belongs to the specified manual" do
        result = described_class.find(content_id: content_id, manual_content_id: manual_content_id)
        expect(result).to eq(section)
      end
    end

    context "with an invalid manual_content_id" do
      it "raises a InvalidManual error" do
        expect {
          described_class.find(content_id: content_id, manual_content_id: SecureRandom.uuid)
        }.to raise_error(Section::RecordNotFound)
      end
    end
  end

  describe ".from_publishing_api" do
    let(:manual_content_id) { SecureRandom.uuid }
    let(:content_item) do
      {
        content_id: content_id,
        title: "Section title",
        description: "Section description",
        details: {body: "## Some body text"},
      }
    end

    context "given a section exists" do
      before do
        publishing_api_has_item(content_item)
        publishing_api_has_links(content_id: content_id, links: { manual: [manual_content_id] })
      end

      subject { described_class.from_publishing_api(content_id: content_id) }

      it "retrieves a content item from the publishing api get_content endpoint by content_id" do
        expect(subject).to be_a(Section)

        assert_publishing_api(:get, "#{Plek.current.find('publishing-api')}/v2/content/#{content_id}")

        expect(subject.content_id).to eq(content_id)
        expect(subject.title).to eq("Section title")
        expect(subject.summary).to eq("Section description")
        expect(subject.body).to eq("## Some body text")
        expect(subject.manual_content_id).to eq(manual_content_id)
      end
    end

    context "when a section doesn't exist for content_id" do
      before do
        publishing_api_does_not_have_item(content_id)
      end

      it "raises an appropriate error" do
        expect {
          described_class.from_publishing_api(content_id: content_id)
        }.to raise_error(Section::RecordNotFound)
      end
    end
  end

  describe "#save" do
    let(:section_content_id) { SecureRandom.uuid }
    let(:another_section_content_id) { SecureRandom.uuid }
    let(:manual_content_id) { SecureRandom.uuid }
    let(:manual_base_path) { "/guidance/manual_path" }

    let(:manual) do
      {content_id: manual_content_id,
       base_path: manual_base_path,
       details: {body: ""}}
    end

    let(:manual_links) do
      {content_id: manual_content_id,
       links: {
         sections: [another_section_content_id]
       }
      }
    end

    let(:test_time) { "2015-12-03 16:59:13 UTC" }

    before do
      stub_publishing_api_put_content(section_content_id, {})
      stub_publishing_api_patch_links(section_content_id, {})
      stub_publishing_api_patch_links(manual_content_id, {})
      publishing_api_has_item(manual)
      publishing_api_has_links(manual_links)
      Timecop.freeze(Time.parse(test_time))

    end

    context "with valid input" do
      let(:test_params) do
        {
          content_id: section_content_id,
          title: "My New section",
          summary: "Summary of new section",
          body: "The body of my new section.",
          manual_content_id: manual_content_id
        }
      end

      let(:expected_params) do
        {
          base_path: "/guidance/manual_path/my-new-section",
          title: "My New section",
          description: "Summary of new section",
          format: "manual_section",
          need_ids: [],
          locale: "en",
          public_updated_at: test_time.to_datetime.rfc3339,
          publishing_app: "specialist-publisher",
          rendering_app: "manuals-frontend",
          details: {
            body: "The body of my new section.",
            manual: {
              base_path: manual_base_path
            },
            organisations: []
          },
          routes: [
            {
              path: "/guidance/manual_path/my-new-section",
              type: "exact"
            }
          ]
        }
      end

      let(:expected_section_links) do
        {links: {manual: [manual_content_id]}}
      end

      let(:expected_manual_links) do
        {links: {sections: [another_section_content_id, section_content_id]}}
      end

      it "should put content to publishing-api" do
        section = Section.new(test_params)
        expect(section.save).to eq(true)
        assert_publishing_api_put_content(section.content_id, request_json_includes(expected_params), 1)
        assert_publishing_api_patch_links(section.content_id, request_json_includes(expected_section_links))
        assert_publishing_api_patch_links(manual_content_id, request_json_includes(expected_manual_links))
      end

      it "should not send duplicated section ids to manual links" do
        publishing_api_has_links({content_id: manual_content_id,
                                  links: {
                                    sections: [another_section_content_id, section_content_id]
                                  }})

        section = Section.new(test_params)
        expect(section.save).to eq(true)
        assert_publishing_api_put_content(section.content_id, request_json_includes(expected_params), 1)
        assert_publishing_api_patch_links(section.content_id, request_json_includes(expected_section_links))
        assert_publishing_api_patch_links(manual_content_id, match_any_body, 0)
      end
    end

    context "with invalid input" do
      it "should NOT put content to publishing-api" do
        test_params = {
          content_id: section_content_id,
          title: "",
          summary: "",
          body: "",
          manual_content_id: manual_content_id
        }

        section = Section.new(test_params)
        expect(section.save).to eq(false)
        assert_publishing_api_put_content(section.content_id, match_any_body, 0)
      end
    end
  end
end
