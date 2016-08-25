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
    used = []
    matched = []
    unmatched = []

    body_snippets.each do |b|
      match = false

      attachment_snippets.each do |a|
        if presenter.snippets_match?(a, b)
          matched.push(b)
          used |= [a]
          match = true
        end
      end

      unmatched.push(b) unless match
    end
    unused = attachment_snippets - used

    filenames_only([used, unused, matched, unmatched])
  end

  def body_snippets
    @body_snippets ||= presenter.snippets_in_body
  end

  def attachment_snippets
    @attachment_snippets ||= document.attachments.map(&:snippet)
  end

  def filenames_only(arrays)
    arrays.map do |array|
      array.map do |snippet|
        snippet[/\[InlineAttachment:(.*?)\]/, 1]
      end
    end
  end

  def presenter
    GovspeakPresenter.new(document)
  end
end
