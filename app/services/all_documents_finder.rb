class AllDocumentsFinder
  def self.all(page, per_page, q, document_type)
    params = {
      publishing_app: "specialist-publisher",
      document_type: document_type,
      fields: [
        :base_path,
        :content_id,
        :last_edited_at,
        :title,
        :publication_state,
        :state_history,
      ],
      page: page,
      per_page: per_page,
      order: "-last_edited_at",
    }
    params[:q] = q if q.present?

    Services.publishing_api.get_content_items(params)
  end
end
