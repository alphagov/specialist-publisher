class AaibImportMapper
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
      raise DocumentHasNewerVersionError, "#{document.slug}"
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
      "summary" => "SHOULD BE REMOVED",
      "title" => title_with_date_if_not_present(data),
      "aircraft_category" => data["aircraft_categories"],
      "report_type" => report_type(data),
    })
  end

  def title_with_date_if_not_present(data)
    occurrence = Date.parse(data["date_of_occurrence"])
    title = data["title"]

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
    when "bulletin" then "bulletin"
    when "special bulletin" then "special-bulletin"
    when "formal report" then "formal-report"
    else raise "Unknown report type: #{data["report_type"]}"
    end
  end

  def desired_keys
    %w(
      title
      summary
      registration_string
      date_of_occurrence
      registrations
      aircraft_category
      report_type
      location
      aircraft_types
      body
    )
  end
end
