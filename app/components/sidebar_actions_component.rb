class SidebarActionsComponent < ViewComponent::Base
  def initialize(document, current_user)
    @document = document
    policy = DocumentPolicy.new(current_user, document.class)
    @presenter = ActionsPresenter.new(@document, policy)
  end

  def render?
    actions.any?
  end

  def actions
    @actions ||= [
      edit_action,
      publish_action,
      unpublish_action,
      discard_draft_action,
    ].compact
  end

  def notices
    notices = []

    notices << notice("Publishing", @presenter.publish_notice) if @presenter.publish_notice.present?
    notices << notice("Unpublishing", @presenter.unpublish_notice) if @presenter.unpublish_notice.present?
    notices << notice("Delete draft", @presenter.discard_draft_notice) if @presenter.discard_draft_notice.present?

    return if notices.empty?

    tag.div(
      render("govuk_publishing_components/components/inset_text", {
        text: notices.join("<br>").html_safe,
      }), class: "app-view-summary__sidebar-notices"
    )
  end

private

  def notice(heading, text)
    [tag.strong(heading), tag.p(text)].join("<br>")
  end

  def edit_action
    render("govuk_publishing_components/components/button", {
      text: "Edit document",
      href: @presenter.edit_path,
      secondary_quiet: true,
    })
  end

  def publish_action
    return unless @presenter.publish_button_visible?

    render("govuk_publishing_components/components/button", {
      text: "Publish document",
      title: "Publish #{@document.title}",
      href: @presenter.confirm_publish_path,
    })
  end

  def unpublish_action
    return unless @presenter.unpublish_button_visible?

    render("govuk_publishing_components/components/button", {
      text: "Unpublish document",
      href: @presenter.confirm_unpublish_path,
      destructive: true,
    })
  end

  def discard_draft_action
    return unless @presenter.discard_button_visible?

    link_to(
      "Delete draft",
      @presenter.confirm_discard_path,
      class: "govuk-link gem-link--destructive",
    )
  end
end
