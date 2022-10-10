require "services"

class Organisation
  def self.all
    @organisations = fetch_all_organisations(organisation_params)
  end

  attr_reader :content_id, :title

  def initialize(attrs)
    @content_id = attrs["content_id"]
    @title = attrs["title"]
  end

  class << self
    def document_type
      "organisation"
    end

    def fetch_all_organisations(params)
      orgs = []
      current_page = 1
      10.times do
        response = Services.publishing_api.get_content_items(params.merge(page: current_page))
        orgs << response["results"].map { |attrs| Organisation.new(attrs) }
        if response["pages"] > current_page
          current_page += 1
        else
          break
        end
      end
      orgs.flatten
    end

    def organisation_params
      {
        document_type:,
        fields: %i[content_id title],
        order: "base_path",
        per_page: "600", # Around ~1070 orgs.
      }
    end
  end
end
