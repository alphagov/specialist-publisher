module ApplicationHelper

  def facet_options(form, facet)
    form.object.facet_options(facet)
  end
end
