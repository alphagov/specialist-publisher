module AaibImport
  class Mapper
    def initialize(document_creator, repo)
      @document_creator = document_creator
      @repo = repo
    end

    def call(raw_data)
      document = document_creator.call(desired_attributes(raw_data))
      if document.valid?
        document
      elsif document.errors.keys == [:slug]
        destroy_newer_version_or_raise(document)
      else
        document
      end
    end

  private
    attr_reader :document_creator, :repo

    def destroy_newer_version_or_raise(document)
      other_document = repo.first_by_slug(document.slug)
      if document == most_recent(document, other_document)
        other_document.destroy
        document
      else
        raise DocumentImport::HasNewerVersionError, "#{document.slug}"
      end
    end

    def most_recent(doc1, doc2)
      [doc1, doc2].sort_by { |d| Date.parse(d.date_of_occurrence) }.last
    end

    def desired_attributes(data)
      massage(data)
        .slice(*desired_keys)
        .symbolize_keys
    end

    def massage(data)
      data.merge({
        "title" => title_with_date_if_not_present(data),
        "aircraft_category" => aircraft_categories(data["aircraft_categories"]),
        "report_type" => report_type(data),
        "body" => body_substitutions(data["body"]),
      })
    end

    def body_substitutions(body)
      body.dup.tap do |new_body|
        {
          "![PDF icon](http://www.aaib.gov.uk/sites/maib/_shared/ico_pdf.gif)" => "",
          /^ +/ => "",
        }.each do |search, replace|
          new_body.gsub!(search, replace)
        end
      end
    end

    def title_with_date_if_not_present(data)
      occurrence = Date.parse(data.fetch("date_of_occurrence"))
      title = data.fetch("title")

      date_from_title = safe_parse_date(title)

      if fuzzy_date_match(date_from_title, occurrence)
        title
      else
        "#{title}, #{occurrence.strftime("%-d %B %Y")}"
      end
    end

    def fuzzy_date_match(date1, date2)
      date1.is_a?(Date) && date2.is_a?(Date) &&
        [date1.month, date1.year] == [date2.month, date2.year]
    end

    def safe_parse_date(string)
      Date.parse(string)
    rescue ArgumentError
      nil
    end

    def report_type(data)
      case data["report_type"]
      when "" then "field-investigation"
      when "correspondence investigation" then "correspondence-investigation"
      when "field investigation" then "field-investigation"
      when "formal report" then "formal-report"
      when "overseas occurrence" then "field-investigation"
      when "special bulletin" then "special-bulletin"
      when "uncategorised" then "pre-1997-uncategorised-monthly-report"
      else raise "Unknown report type: #{data["report_type"]}"
      end
    end

    def aircraft_categories(categories)
      categories.map { |c| aircraft_category(c) }
    end

    def aircraft_category(category)
      case category
      when "Commercial Air Transport - Fixed Wing" then "commercial-fixed-wing"
      when "Commercial Air Transport - Rotorcraft" then "commercial-rotorcraft"
      when "General Aviation - Fixed Wing" then "general-aviation-fixed-wing"
      when "General Aviation - Rotorcraft" then "general-aviation-rotorcraft"
      when "Sport Aviation/Balloons" then "sport-aviation-and-balloons"
      else raise "Unknown aircraft category: #{category}"
      end
    end

    def desired_keys
      %w(
        aircraft_category
        aircraft_types
        body
        date_of_occurrence
        location
        registration_string
        registrations
        report_type
        summary
        title
      )
    end
  end
end
