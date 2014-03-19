module CMAImporter
  class DocumentImporter
    def initialize(case_data)
      @case_data = case_data.dup

      @case_data.each do |k, v|
        @case_data.delete(k) if v.blank?
      end

      @case_data['original_urls'] ||= Array(@case_data.delete('original_url'))
    end

    attr_reader :case_data
  end
end
