require 'spec_helper'
require 'cma_importer/document_importer'

describe CMAImporter::DocumentImporter do
  describe '#new' do
    it 'removes blank values from the data' do
      importer = CMAImporter::DocumentImporter.new('directory', {
        here: 'hello',
        not_here: '',
        'also_not_here' => nil
      }, 'path')

      expect(importer.case_data).to include(here: 'hello')
      expect(importer.case_data).not_to include(:not_here, 'also_not_here')
    end

    it 'sets "original_urls" to an array of the value of "original_url"' do
      importer = CMAImporter::DocumentImporter.new('directory', {
        'original_url' => 'hello'
      }, 'path')

      expect(importer.case_data).to include('original_urls' => ['hello'])
    end
  end
end
