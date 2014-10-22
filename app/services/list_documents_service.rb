class ListDocumentsService

  def initialize(documents_repository, search_details)
    @documents_repository = documents_repository
    @search_details = search_details
  end

  def call
    if search_details.term.present?
      documents_repository.send(search_method, search_details.term)
    else
      documents_repository
    end
  end

private
  attr_reader :documents_repository, :search_details

  def search_method
    "by_#{search_details.attribute}"
  end
end
