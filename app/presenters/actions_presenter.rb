class ActionsPresenter
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::TagHelper

  attr_accessor :document, :policy

  def initialize(document, policy)
    self.document = document
    self.policy = policy
  end

  def edit_path
    edit_document_path(slug, document.content_id_and_locale)
  end

  def publish_button_visible?
    policy.publish? && document.draft?
  end

  def publish_text
    if update_type == "minor"
      "You are about to publish a minor edit."
    elsif update_type == "major" && !document.first_draft?
      "You are about to publish a major edit with a public change note. Publishing will email subscribers to #{klass_name}."
    else
      "Publishing will email subscribers to #{klass_name}."
    end
  end

  def confirm_publish_path
    confirm_publish_document_path(slug, document.content_id_and_locale)
  end

  def confirm_unpublish_path
    confirm_unpublish_document_path(slug, document.content_id_and_locale)
  end

  def confirm_discard_path
    confirm_discard_document_path(slug, document.content_id_and_locale)
  end

  def publish_path
    publish_document_path(slug, document.content_id_and_locale)
  end

  def unpublish_button_visible?
    policy.unpublish? && state == "published"
  end

  def publish_notice
    if !policy.publish? && document.draft?
      "You don't have permission to publish this document."
    end
  end

  def unpublish_notice
    return if document.first_draft?

    if state == "draft"
      "The document cannot be unpublished because it has a draft. You need to publish the draft first."
    elsif !policy.unpublish? && state == "published"
      "You don't have permission to unpublish this document."
    end
  end

  def unpublish_path
    unpublish_document_path(slug, document.content_id_and_locale)
  end

  def discard_button_visible?
    policy.discard? && document.draft?
  end

  def discard_path
    discard_document_path(slug, document.content_id_and_locale)
  end

  def discard_draft_notice
    if !policy.discard? && document.draft?
      "You don't have permission to delete this draft."
    end
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
    document.class.admin_slug
  end
end
