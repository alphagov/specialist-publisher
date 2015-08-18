# encoding: UTF-8

module ApplicationHelper
  def state(document)
    state = document.publication_state

    if %w(published withdrawn).include?(state) && document.draft?
      state << " with new draft"
    end

    if document.draft?
      classes = "label label-primary"
    else
      classes = "label label-default"
    end

    content_tag(:span, state, class: classes).html_safe

  end

  def show_preview?(item)
    if item.respond_to?(:documents)
      item.draft? || item.documents.any?(&:draft?)
    else
      item.draft?
    end
  end

  def publication_task_state(task)
    zoned_time = time_with_local_zone(task.updated_at)
    formatted_time = nice_time_format(zoned_time)

    output =  case task.state
              when "queued", "processing"
                %Q(This manual was sent for publishing at #{formatted_time}.
                  It should be published shortly.)
              when "finished"
                %Q(This manual was last published at #{formatted_time}.)
              when "aborted"
                %Q(This manual was sent for publishing at #{formatted_time},
                  but something went wrong. Our team has been notified.)
              end

    output.html_safe
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

  def preview_path_for_manual(manual)
    if manual.persisted?
      preview_manual_path(manual)
    else
      preview_new_manual_path
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
    "#{Plek.current.website_root}/#{manual.slug}"
  end

  def url_for_public_org(organisation_slug)
    "#{Plek.current.website_root}/government/organisations/#{organisation_slug}"
  end

  def content_preview_url(document)
    "#{Plek.current.find("draft-origin")}/#{document.slug}"
  end

  def publish_form(slug_unique, publishable, document)
    publish_form_text = publish_text_hash(document)
    if !current_user_can_publish?(document.document_type) || !slug_unique || !publishable
      if !current_user_can_publish?(document.document_type)
        publish_locals = publish_form_text[:no_permission]
      elsif !publishable
        publish_locals = publish_form_text[:already_published]
      elsif !slug_unique
        publish_locals = publish_form_text[:slug_not_unique]
      end
    elsif publishable
      if !document.change_note.blank? && document.change_note != "First published."
        publish_locals = publish_form_text[:major_update]
      elsif document.minor_update
        publish_locals = publish_form_text[:minor_update]
      else
        publish_locals = publish_form_text[:new_document]
      end
    end
    render partial: "specialist_documents/publish_form", locals: {
      warning: publish_locals[:warning],
      notification: publish_locals[:notification],
      disabled: publish_locals[:disabled],
      document: document
    }
  end

private
  def publish_text_hash(document)
    {
      no_permission: {
        disabled: true,
        warning: nil,
        notification: "You don’t have permission to publish this document.",
      },
      already_published: {
        disabled: true,
        warning: nil,
        notification: "There are no changes to publish.",
      },
      slug_not_unique: {
        disabled: true,
        warning: "You can’t publish this document",
        notification: "This document has a duplicate slug.<br/> You need to #{link_to "edit the document", [:edit, document]} and change the title to be able to be published.",
      },
      major_update: {
        disabled: false,
        warning: "You are about to publish a <strong>major edit</strong> with a public change note.",
        notification: "Publishing will email subscribers to #{current_finder[:title]}.",
      },
      minor_update: {
        disabled: false,
        warning: nil,
        notification: "You are about to publish a <strong>minor edit</strong>.",
      },
      new_document: {
        disabled: false,
        warning: nil,
        notification: "Publishing will email subscribers to #{current_finder[:title]}.",
      }
    }
  end

end
