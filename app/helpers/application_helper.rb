module ApplicationHelper
  def facet_options(form, facet)
    form.object.facet_options(facet)
  end

  def state(document)
    state = document.publication_state == "live" ? "published" : document.publication_state

    if document.publication_state == "draft"
      classes = "label label-primary"
    else
      classes = "label label-default"
    end

    content_tag(:span, state, class: classes).html_safe
  end
end
