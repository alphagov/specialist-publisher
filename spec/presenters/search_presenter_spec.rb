require 'spec_helper'

describe SearchPresenter do
  subject(:presenter) { SearchPresenter.new(document) }

  let(:aaib_content_id) { "38eb5d8f-2d89-480c-8655-e2e7ac23f8f4" }
  let(:court)           { "b0bdfcf3-2763-4002-961e-a0b2d7825038" }

  let(:organisations) {
    [
      { "content_id" => aaib_content_id,
        "base_path"  => "/government/organisations/air-accidents-investigation-branch" },
      { "content_id" => "0398096c-6742-4cf3-934a-09fa70309beb",
        "base_path"  =>
          "/government/organisations/inquiry-into-the-supervision-of-the-bank-of-credit-and-commerce-international" },
      { "content_id" => court,
        "base_path"  => "/courts-tribunals/administrative-court" }
    ]
  }

  before do
    publishing_api_has_linkables(organisations, document_type: 'organisation')
  end

  context 'a complete document is given' do
    let(:document) do
      double(
        'Document',
        title:                    'A Title',
        summary:                  'A summary',
        base_path:                '/some-finder/a-title',
        organisations:            [aaib_content_id, court],
        public_updated_at:        Time.now,
        body:                     '## A Title',
        format_specific_metadata: { country: ['GB'], blank_value: '' }
      )
    end

    describe '#indexable_content' do
      it 'indexes the body alone' do
        expect(presenter.indexable_content).to eql('## A Title')
      end
    end

    describe '#to_json' do
      subject(:json) { presenter.to_json }

      it 'has values that are present' do
        expect(json[:title]).to eql('A Title')
        expect(json[:link]).to eql(document.base_path)
      end

      it 'includes format-specific metadata' do
        expect(json[:country]).to eql(['GB'])
      end

      it 'does not include blank values' do
        expect { json.fetch(:blank_value) }.to raise_error(KeyError)
      end
    end

    describe '#organisations_slugs' do
      subject(:organisation_slugs) { presenter.organisation_slugs }

      it 'gets slugs with a content-id in the document\'s organisations' do
        expect(organisation_slugs).to eql(
          %w(air-accidents-investigation-branch administrative-court))
      end
    end
  end
end
