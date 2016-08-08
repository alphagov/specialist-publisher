class ActionsPresenter
  include Rails.application.routes.url_helpers

  attr_accessor :document, :policy

  def initialize(document, policy)
    self.document = document
    self.policy = policy
  end

  def edit_path
    edit_document_path(slug, document.content_id)
  end

  def publish_button_visible?
    policy.publish? && document.draft?
  end

  def publish_text
    if state == "published"
      text = "<p>There are no changes to publish.</p>"
    elsif state == "unpublished"
      text = "<p>The document is unpublished. You need to create a new draft before it can be published.</p>"
    elsif !policy.publish?
      text = "<p>You don't have permission to publish this document.</p>"
    elsif update_type == "minor"
      text = "<p>You are about to publish a <strong>minor edit</strong>.</p>"
    elsif update_type == "major" && !document.first_draft?
      text = "<p><strong>You are about to publish a major edit with a public change note.</strong></p>"
      text += "<p>Publishing will email subscribers to #{klass_name}.</p>"
    else
      text = "<p>Publishing will email subscribers to #{klass_name}.</p>"
    end

    text.html_safe
  end

  def publish_alert
    if update_type == 'minor'
      "You are about to publish a minor edit. Continue?"
    else
      "Publishing will email subscribers to #{document.class.title.pluralize}. Continue?"
    end
  end

  def publish_path
    publish_document_path(slug, document.content_id)
  end

  def unpublish_button_visible?
    policy.unpublish? && state == "published"
  end

  def unpublish_text
    if document.first_draft?
      text = "<p>The document has never been published.</p>"
    elsif state == "draft"
      text = "<p>The document cannot be unpublished because it has a draft. You need to publish the draft first.</p>"
    elsif state == "unpublished"
      text = "<p>The document is already unpublished.</p>"
    elsif !policy.unpublish?
      text = "<p>You don't have permission to unpublish this document.</p>"
    elsif state == "published"
      text = "<p>The document will be removed from the site. It will still be possible to edit and publish a new version.</p>"
    else
      raise ArgumentError, "Unrecognised state: '#{state}'"
    end

    text.html_safe
  end

  def unpublish_alert
    "Are you sure you want to unpublish this document?"
  end

  def unpublish_path
    unpublish_document_path(slug, document.content_id)
  end

private

  def state
    document.publication_state
  end

  def update_type
    document.update_type
  end

  def klass_name
    document.class.title.pluralize
  end

  def slug
    document.class.slug
  end
end
