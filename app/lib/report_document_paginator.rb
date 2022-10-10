require "services"

class ReportDocumentPaginator
  def initialize(document_class, document_fields, param_options = {})
    @document_class = document_class
    @document_fields = document_fields
    @params_hash = default_params.merge(param_options)
  end

  def each(&block)
    page = 1
    loop do
      response = Services.publishing_api.get_content_items(params(page))
      break if response["results"].empty?

      response["results"].each(&block)
      break if response["current_page"] >= response["pages"]

      page += 1
    end
  end

private

  def params(page)
    @params_hash.merge(page:)
  end

  def default_params
    {
      publishing_app: "specialist-publisher",
      document_type:,
      fields: @document_fields,
      per_page: 100,
      order: "-last_edited_at",
    }
  end

  def document_type
    @document_type ||= @document_class.document_type
  end
end
