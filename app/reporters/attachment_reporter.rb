class AttachmentReporter
  def self.report(document)
    new(document).report
  end

  def initialize(document)
    self.document = document
  end

  def report
    used, unused, matched, unmatched = build_report_data

    {
      attachment_counts: {
        used: used.count,
        unused: unused.count,
      },
      snippet_counts: {
        matched: matched.count,
        unmatched: unmatched.count,
      },
      unused_attachments: unused,
      unmatched_snippets: unmatched,
    }
  end

private

  attr_accessor :document

  def build_report_data
    sanitised_attachment_snippets = attachment_snippets.map { |s| s[:sanitised_snippet] }
    sanitised_body_snippets = body_snippets.map { |s| s[:sanitised_snippet] }

    unused_sanitised_attachment_snippets = sanitised_attachment_snippets - sanitised_body_snippets
    unused_sanitised_body_snippets = sanitised_body_snippets - sanitised_attachment_snippets

    used = used_attachments(attachment_snippets, sanitised_attachment_snippets - unused_sanitised_attachment_snippets)
    unused = unused_attachments(attachment_snippets, unused_sanitised_attachment_snippets)

    matched = match_snippets(body_snippets, sanitised_body_snippets - unused_sanitised_body_snippets)
    unmatched = match_snippets(body_snippets, unused_sanitised_body_snippets)

    [used, unused, matched, unmatched].map { |arr| filenames_only(arr) }
  end

  def body_snippets
    @body_snippets ||= presenter.snippets_in_body.map do |snippet|
      {
        snippet:,
        sanitised_snippet: sanitise_snippet(snippet),
        filename: filename_from_snippet(snippet),
      }
    end
  end

  def attachment_snippets
    @attachment_snippets ||= document.attachments.map do |attachment|
      {
        snippet: attachment.snippet,
        sanitised_snippet: sanitise_snippet(attachment.snippet),
        filename: filename_from_snippet(attachment.snippet),
      }
    end
  end

  def sanitise_snippet(snippet)
    presenter.sanitise_snippet(snippet)
  end

  def used_attachments(attachment_snippets, matched_sanitised_snippets)
    # only match first instance of an attachment with a non-unique sanitised
    # snippet, as latter ones will be ignored.
    first_attachments = attachment_snippets.uniq { |a| a[:sanitised_snippet] }
    match_snippets(first_attachments, matched_sanitised_snippets)
  end

  def unused_attachments(attachment_snippets, matched_sanitised_snippets)
    # include attachments that have a non-unique sanitised snippet ignoring
    # their first occurence as they won't be matched.
    occurences = Hash.new(0)
    attachment_snippets.select do |s|
      sanitised_snippet = s[:sanitised_snippet]
      occurences[sanitised_snippet] += 1
      matched_sanitised_snippets.include?(sanitised_snippet) || occurences[sanitised_snippet] > 1
    end
  end

  def match_snippets(snippets, matched_sanitised_snippets)
    snippets.select { |s| matched_sanitised_snippets.include?(s[:sanitised_snippet]) }
  end

  def filenames_only(snippets)
    snippets.map { |s| s[:filename] }
  end

  def filename_from_snippet(snippet)
    snippet[/\[InlineAttachment:(.*?)\]/, 1]
  end

  def presenter
    GovspeakPresenter.new(document)
  end
end
