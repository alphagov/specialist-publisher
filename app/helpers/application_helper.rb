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

  def publish_warning(document)
    if document.update_type == 'minor'
      message = '<p>You are about to publish a <strong>minor edit</strong>.</p>'
    elsif document.update_type == 'major' && document.redrafted?
      message = '<strong>You are about to publish a major edit with a public change note.</strong>
      <p>Publishing will email subscribers to ' + document.class.title.pluralize + '.</p>'
    else
      message = '<p>Publishing will email subscribers to ' + document.class.title.pluralize + '.</p>'
    end
    message.html_safe
  end

  def pop_up_warning_for_publishing(document)
    if document.update_type == 'minor'
      "You are about to publish a minor edit. Continue?"
    else
      "Publishing will email subscribers to #{document.class.title.pluralize}. Continue?"
    end
  end
end
