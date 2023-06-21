require "services"

# Request all documents for a certain document type, paginated
class AllDocumentsFinder
  def self.default_find_params(document_type)
    {
      publishing_app: "specialist-publisher",
      document_type:,
      order: "-last_edited_at",
      locale: "all",
    }
  end

  def self.all(page, per_page, query, document_type, organisation)
    params = default_find_params(document_type).merge(
      fields: %i[
        base_path
        content_id
        locale
        last_edited_at
        title
        publication_state
        state_history
      ],
      page:,
      per_page:,
      order: "-last_edited_at",
    )

    (params[:q] = query) if query.present?
    if organisation != "all" && organisation
      params[:link_organisations] = organisation
    end

    Services.publishing_api.get_content_items(params)
  end

  def self.find_each(klass, query: nil)
    params = default_find_params(klass.document_type).merge(per_page: 50)
    params[:q] = query if query.present?

    current_page = 1
    loop do
      response = Services.publishing_api.get_content_items(params.merge(page: current_page))

      response["results"].each do |document|
        yield klass.from_publishing_api(document)
      end
      if response["pages"] > current_page
        current_page += 1
      else
        break
      end
    end
  end
end
