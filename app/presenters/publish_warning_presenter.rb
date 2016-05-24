class PublishWarningPresenter
  def publish_warning(document)
    if document.update_type == 'minor'
      '<p>You are about to publish a <strong>minor edit</strong>.</p>'
    elsif document.update_type == 'major' && document.redrafted?
      '<strong>You are about to publish a major edit with a public change note.</strong>
      <p>Publishing will email subscribers to ' + document.class.title.pluralize + '.</p>'
    else
      '<p>Publishing will email subscribers to ' + document.class.title.pluralize + '.</p>'
    end
  end
end
