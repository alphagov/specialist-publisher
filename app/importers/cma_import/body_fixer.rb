# A number of the scraped JSON files contain markup_sections which aren't
# included in the body. This object:
#
# - works out which sections are missing
# - adds those sections into the body if it can
# - adds a warning to the import notes if it can't
class CmaImportBodyFixer
  def initialize(create_document_service:)
    @create_document_service = create_document_service
  end

  def call(data)
    massager = DataMassager.new(raw_data: data)

    document = create_document_service.call(massager.massaged_data)

    Presenter.new(
      document: document,
      massager: massager,
    )
  end

private
  attr_reader :create_document_service

  class DataMassager
    def initialize(raw_data:)
      @raw_data = raw_data
    end

    def massaged_data
      raw_data.merge("body" => massaged_body)
    end

    def body_complete?
      missing_sections.empty?
    end

    def missing_section_keys
      missing_sections.keys
    end

    def fixed_body?
      only_missing_final_report_and_appendices_section?
    end

  private
    attr_reader :raw_data

    def massaged_body
      if fixed_body?
        [body, missing_content].join("\n\n")
      else
        body
      end
    end

    def body
      raw_data.fetch("body", "")
    end

    def normalised_body
      body.gsub(/\s+/, " ")
    end

    def markup_sections
      raw_data.fetch("markup_sections", {})
    end

    def missing_content
      missing_sections.values.map { |content|
        down_level_headings(content)
      }
    end

    def missing_sections
      markup_sections.reject { |_, content|
        section_appears_in_body?(content)
      }
    end

    def section_appears_in_body?(section_content)
      normalised_content = section_content.gsub(/\s+/, " ")
      reheaded_content = down_level_headings(normalised_content)

      normalised_body.include?(normalised_content) || normalised_body.include?(reheaded_content)
    end

    def only_missing_final_report_and_appendices_section?
      missing_sections.keys == %w(final-report-and-appendices-glossary)
    end

    # Swap all headings with a heading one level lower. This is done by finding
    # all lines that start with a `#` and adding another one
    def down_level_headings(content)
      content.gsub(/^#/, "##")
    end
  end

  class Presenter < SimpleDelegator
    def initialize(document:, massager:)
      @massager = massager

      super(document)
    end

    def import_notes
      super + messages
    end

  private
    attr_reader :massager

    def messages
      [
        incomplete_body_message,
        body_fixed_automatically_message,
      ].compact
    end

    def incomplete_body_message
      unless massager.body_complete?
        "Body missing some markup sections: #{missing_sections}"
      end
    end

    def body_fixed_automatically_message
      if massager.fixed_body?
        "Missing body sections added automatically"
      end
    end

    def missing_sections
      massager.missing_section_keys.join(", ")
    end
  end
end
