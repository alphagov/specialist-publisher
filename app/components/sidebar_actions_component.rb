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

    notices << notice("Publishing", @presenter.publish_text) if @presenter.publish_button_visible?

    notices << notice("Unpublishing", @presenter.unpublish_text)

    return unless notices

    render("govuk_publishing_components/components/inset_text", {
      text: notices.join("<br>").html_safe,
    })
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
      href: "#",
    })
  end

  def unpublish_action
    return unless @presenter.unpublish_button_visible?

    render("govuk_publishing_components/components/button", {
      text: "Unpublish document",
      href: "#",
      destructive: true,
    })
  end

  def discard_draft_action
    return unless @presenter.discard_button_visible?

    link_to(
      "Delete draft",
      "#",
      class: "govuk-link gem-link--destructive",
    )
  end
end
