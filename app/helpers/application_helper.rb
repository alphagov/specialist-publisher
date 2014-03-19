module ApplicationHelper
  def facet_options(facet)
    finder_schema.options_for(facet)
  end
end
