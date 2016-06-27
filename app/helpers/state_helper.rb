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

  def last_two_states(state_history)
    ordered_history = state_history.sort_by { |k, _v| Integer(k.to_s) }
    ordered_history.map!(&:second)
    [ordered_history[-2], ordered_history[-1]]
  end
end
