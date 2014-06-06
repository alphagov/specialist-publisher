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

  def nav_link_to(text, href)
    link_to(text, href)
  end

  def bootstrap_class_for(flash_type)
    case flash_type
      when :success
        "alert-success" # Green
      when :error
        "alert-danger" # Red
      when :alert
        "alert-warning" # Yellow
      when :notice
        "alert-info" # Blue
      else
        flash_type.to_s
    end
  end

  def govspeak(text)
    if text
      content_tag(:div, Govspeak::Document.new(text).to_sanitized_html.html_safe, class: "govspeak")
    end
  end

  def preview_path_for_specialist_document(document)
    if document.persisted?
      preview_specialist_document_path(document)
    else
      preview_new_specialist_document_path
    end
  end

  def preview_path_for_manual_document(manual, document)
    if document.persisted?
      preview_manual_document_path(manual, document)
    else
      preview_new_manual_document_path(manual)
    end
  end

  def url_for_public_manual(manual)
    "#{MANUAL_CONTENT_URL}/#{manual.slug}"
  end
end
