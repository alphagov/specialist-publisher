module StateHelper
  def state_for_frontend(document)
    state = compose_state(document.state_history.to_h)

    if state =~ /draft/
      classes = "label label-primary"
    else
      classes = "label label-default"
    end

    content_tag(:span, state, class: classes).html_safe
  end

  def compose_state(state_history)
    previous_state, latest_state = last_two_states(state_history)
    if previous_state && latest_state == "draft"
      "#{previous_state} with new draft"
    else
      latest_state
    end
  end

  def ordered_history(state_history)
    ordered_history = state_history.sort_by { |k, _v| Integer(k.to_s) }
    ordered_history.map!(&:second)
  end

  def last_two_states(state_history)
    history = ordered_history(state_history)
    [history[-2], history[-1]]
  end

  def show_view_on_website_link?(state_history)
    last_two_states(state_history).include?("published")
  end

  def show_preview_draft_link?(state_history)
    ordered_history(state_history).last == "draft"
  end
end
