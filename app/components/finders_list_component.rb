class FindersListComponent < ViewComponent::Base
  attr_reader :finders

  def initialize(finders)
    @finders = finders
  end

  def list_items
    finders.sort_by(&:document_title).map do |format|
      {
        link: {
          text: format.document_title.pluralize,
          path: helpers.finder_path(document_type_slug: format.admin_slug),
          description: format.description,
        },
      }
    end
  end
end
