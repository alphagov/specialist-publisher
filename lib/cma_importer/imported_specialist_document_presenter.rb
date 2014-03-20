module CMAImporter
  class ImportedSpecialistDocumentPresenter
    attr_reader :case_data

    def initialize(case_data)
      @case_data = case_data
      @attachment_titles = {}
      body # Initialize attachment titles
    end

    attr_reader :attachment_titles

    def to_hash
      {
        title: case_data['title'],
        summary: case_data['summary'],
        body: body,
        case_type: case_data['case_type'],
        case_state: case_data['case_state'],
        market_sector: case_data['sector'],
        state: 'draft',
        version_number: 1,
        opened_date: case_data['opened_date']
      }
    end

    def body
      @body ||= body_with_links.gsub(/\[([^\]]+)\]\(([^)]+pdf)\)/) do
        link_text, link = $1, $2
        filename = link.split('/').last

        @attachment_titles[link] = link_text

        "[InlineAttachment:#{filename}]"
      end
    end

    def body_with_links
      if case_data.has_key?('body')
        case_data.fetch('body')
      else
        [
          decision_body,
          initial_undertakings_body,
          invitation_to_comment_body
        ].compact.join("\n\n")
      end
    end

    def decision_body
      if case_data.has_key?('decision')
        "# Decision\n\n#{case_data['decision']}\n\n"
      end
    end

    def initial_undertakings_body
      if case_data.has_key?('initial_undertakings')
        "# Initial undertakings\n\n#{case_data['initial_undertakings']}\n\n"
      end
    end

    def invitation_to_comment_body
      if case_data.has_key?('invitation_to_comment')
        "# Invitation to comment\n\n#{case_data['invitation_to_comment']}\n\n"
      end
    end
  end
end
