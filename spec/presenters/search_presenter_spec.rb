require 'spec_helper'

RSpec.describe SearchPresenter do
  subject(:presenter) { SearchPresenter.new(document) }

  context 'a complete document is given' do
    let(:document_fields) do
      {
          title: 'A Title',
          document_type: 'document_type',
          summary: 'A summary',
          base_path: '/some-finder/a-title',
          public_updated_at: Time.now,
          first_published_at: Time.now,
          body: '## A Title',
          format_specific_metadata: { country: ['GB'], blank_value: '' }
      }
    end

    let(:document) do
      double(
        'Document',
          document_fields
      )
    end

    let(:document_with_hidden_content) do
      double(
        'Document',
          document_fields.merge(hidden_indexable_content: 'hidden content'))
    end

    describe '#indexable_content' do
      it 'indexes the body alone' do
        expect(presenter.indexable_content).to eql('A Title')
      end

      it 'includes hidden_indexable_content when present in document' do
        expect(SearchPresenter.new(document_with_hidden_content).indexable_content).to eql('A Title' + ' ' + 'hidden content')
      end
    end

    describe '#to_json' do
      subject(:json) { presenter.to_json }

      it 'has values that are present' do
        expect(json[:title]).to eql('A Title')
        expect(json[:link]).to eql(document.base_path)
      end

      it 'has attribute "content_store_document_type" with value of "document_type"' do
        expect(json[:content_store_document_type]).to eql('document_type')
        expect(json[:content_store_document_type]).to eql(document.document_type)
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
