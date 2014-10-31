module DrugSafetyUpdateImport
  class Mapper
    def initialize(document_creator, repo)
      @document_creator = document_creator
      @repo = repo
    end

    def call(raw_data)
      document = document_creator.call(desired_attributes(raw_data))
      document
    end

  private
    attr_reader :document_creator, :repo

    def desired_attributes(data)
      massage(data)
        .slice(*desired_keys)
        .symbolize_keys
    end

    def massage(data)
      data.merge({
        "title" => data["title"],
        "assets" => [],
        "body" => data["body"],
        "first_published_at" => Time.utc(data["first_published_at"])
      })
    end

    def desired_keys
      %w(
        body
        title
        summary
        therapeutic_area
        first_published_at
      )
    end
  end
end
