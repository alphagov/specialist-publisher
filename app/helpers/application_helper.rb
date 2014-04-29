module ApplicationHelper
  def facet_options(facet)
    finder_schema.options_for(facet)
  end

  def document_state(document)
    state = document.publication_state

    if %w(published withdrawn).include?(state) && document.draft?
      state << ' with new draft'
    end

    state
  end
end
