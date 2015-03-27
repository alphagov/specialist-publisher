class ListDocumentsService

  def initialize(documents_repository, search_details)
    @documents_repository = documents_repository
    @search_details = search_details
  end

  def call
    if search_details.query.present?
      documents_repository.search(search_details.query)
    else
      documents_repository
    end
  end

private
  attr_reader :documents_repository, :search_details
end
