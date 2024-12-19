class FinderMetadataSummaryCardComponent < ViewComponent::Base
  def initialize(schema, previous_schema: nil, summary_card_actions: [])
    @schema = schema
    @previous_schema = previous_schema
    @summary_card_actions = summary_card_actions
  end

  def render_finder_summary_rows
    [
      ({
        key: "Title of the finder",
        value: @schema.name
      } if @previous_schema.nil? || @schema.name != @previous_schema.name),
      ({
        key: "Slug or URL",
        value: @schema.base_path
      } if @previous_schema.nil? || @schema.base_path != @previous_schema.base_path),
      ({
        key: "Organisations the finder should be attached to",
        value: (@schema.organisations || []).map { |content_id| helpers.organisation_name(content_id) }.compact.join(",")
      } if @previous_schema.nil? || @schema.organisations != @previous_schema.organisations),
      ({
        key: "Short description (For search engines)",
        value: @schema.description
      } if @previous_schema.nil? || @schema.description != @previous_schema.description),
      ({
        key: "Summary of the finder (Longer description shown below title)",
        value: sanitize("<div class='govspeak'>#{@schema.summary}</div>")
      } if @previous_schema.nil? || @schema.summary != @previous_schema.summary),
      ({
        key: "Any related links on GOV.UK?",
        value: related_links_value,
      } if @previous_schema.nil? || @schema.related != @previous_schema.related),
      ({
        key: "Should summary of each content show under the title in the finder list page?",
        value: @schema.show_summaries ? "Yes" : "No"
      } if @previous_schema.nil? || @schema.show_summaries != @previous_schema.show_summaries),
      ({
        key: "The document noun (How the documents on the finder are referred to)",
        value: (@schema.document_noun || "").humanize
      } if @previous_schema.nil? || @schema.document_noun != @previous_schema.document_noun),
      ({
        key: "Would you like to set up email alerts for the finder?",
        value: @schema.signup_content_id.present? ? "Yes" : "No"
      } if @previous_schema.nil? || (@schema.signup_content_id.present? != @previous_schema.signup_content_id.present?))
    ].compact
  end

private

  def related_links_value
    if @schema.related
      related_links_content = "Yes"
      @schema.related.each_with_index do |content_id, index|
        related_links_content << sanitize("<p>Link #{index + 1}: #{content_id}</p>")
      end
      related_links_content
    else
      "No"
    end
  end
end