require 'spec_helper'

RSpec.describe SearchPresenter do
  subject(:presenter) { SearchPresenter.new(document) }

  context 'a complete document is given' do
    let(:document) do
      double(
        'Document',
        title:                    'A Title',
        summary:                  'A summary',
        base_path:                '/some-finder/a-title',
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
  end
end
