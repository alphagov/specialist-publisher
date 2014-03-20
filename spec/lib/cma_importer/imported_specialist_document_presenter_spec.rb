require 'spec_helper'
require 'cma_importer/imported_specialist_document_presenter'

describe CMAImporter::ImportedSpecialistDocumentPresenter do
  describe '#body' do
    it 'replaces PDF link markdown with attachment govspeak' do
      presenter = CMAImporter::ImportedSpecialistDocumentPresenter.new({
        'body' => "[A title](http://www.example.com/test.pdf)"
      })

      expect(presenter.body).to eq("[InlineAttachment:test.pdf]")
    end

    it 'replaces PDF path markdown with attachment govspeak' do
      presenter = CMAImporter::ImportedSpecialistDocumentPresenter.new({
        'body' => "[A title](/test.pdf)"
      })

      expect(presenter.body).to eq("[InlineAttachment:test.pdf]")
    end

    it 'leaves non-PDF links alone' do
      presenter = CMAImporter::ImportedSpecialistDocumentPresenter.new({
        'body' => "[A title](http://www.example.com/test.html)"
      })

      expect(presenter.body).to eq("[A title](http://www.example.com/test.html)")
    end

    it 'keeps track of replaced PDF links' do
      presenter = CMAImporter::ImportedSpecialistDocumentPresenter.new({
        'body' => "[A URL title](http://www.example.com/test.pdf)
                   [A path title](/test.pdf)"
      })

      expect(presenter.attachment_titles).to eq({
        'http://www.example.com/test.pdf' => 'A URL title',
        '/test.pdf' => 'A path title'
      })
    end
  end
end
